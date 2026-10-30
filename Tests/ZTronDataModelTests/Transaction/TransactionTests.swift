import XCTest
import SQLite
import SQLite3
@testable import ZTronDataModel

/// Reproduces the "database is locked" crash seen in production (ZTronHomePageModel.loadGames,
/// ZTronMapSelection, ZTronMapToolsPicker each open their own connection and BEGIN EXCLUSIVE
/// TRANSACTION independently). DBMSService never configures a busy_timeout, so as soon as a
/// second connection tries to take the exclusive lock while a first transaction is still open,
/// SQLite fails immediately instead of waiting. Two connections are enough to prove this -
/// true thread concurrency isn't required, since the lock is per-connection, not per-thread.
final class TransactionTests: XCTestCase {

    public final func testAPermanentlyHeldLockFinallyTimesOut() throws {
        // Mirrors the first view's Task.detached: opens its own connection and
        // starts a transaction it hasn't committed/rolled back yet.
        let holderConnection = try DBMSMockProvider.openDB(caller: #function)
        try holderConnection.run("BEGIN EXCLUSIVE TRANSACTION")

        defer {
            try? holderConnection.run("ROLLBACK TRANSACTION")
        }

        // Mirrors a second view (e.g. ZTronMapSelection) opening its own connection
        // and trying to BEGIN EXCLUSIVE TRANSACTION while the first is still open.
        let contenderConnection = try DBMSMockProvider.openDB(caller: #function)

        XCTAssertThrowsError(
            try contenderConnection.run("BEGIN EXCLUSIVE TRANSACTION"),
            "Expected the second, concurrent transaction attempt to fail"
        ) { error in
            XCTAssertTrue(
                "\(error)".lowercased().contains("locked"),
                "Expected a 'database is locked' SQLITE_BUSY error, got: \(error)"
            )
        }
    }
    
    public final func testContenderWaitsForLockInsteadOfFailingImmediately() throws {
        let holderIsReady = DispatchSemaphore(value: 0)
        let releaseHolder = DispatchSemaphore(value: 0)
        var holderError: Error?

        let holderThread = Thread {
            do {
                let holderConnection = try DBMSMockProvider.openDB(caller: #function)
                try holderConnection.run("BEGIN EXCLUSIVE TRANSACTION")
                holderIsReady.signal()

                releaseHolder.wait()
                // Simulate the holder still doing a little work after the contender
                // starts waiting, so we can prove the contender actually waited for it
                // rather than winning a race by coincidence.
                Thread.sleep(forTimeInterval: 0.3)
                try? holderConnection.run("ROLLBACK TRANSACTION")
            } catch {
                holderError = error
            }
        }
        holderThread.start()

        holderIsReady.wait()

        let contenderConnection = try DBMSMockProvider.openDB(caller: #function)
        releaseHolder.signal()

        let start = Date()
        // Without the fix, this throws "database is locked" immediately.
        try contenderConnection.run("BEGIN EXCLUSIVE TRANSACTION")
        let waited = Date().timeIntervalSince(start)
        try? contenderConnection.run("ROLLBACK TRANSACTION")

        while !holderThread.isFinished {
            Thread.sleep(forTimeInterval: 0.01)
        }

        XCTAssertNil(holderError, "Holder transaction should complete normally")
        XCTAssertGreaterThan(
            waited, 0.2,
            "Expected the contender to actually wait for the holder's lock to release, not fail/succeed instantly"
        )
    }

}
