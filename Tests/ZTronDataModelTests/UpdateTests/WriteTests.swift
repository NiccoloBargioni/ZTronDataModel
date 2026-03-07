import XCTest
import SQLite
import SQLite3
@testable import ZTronDataModel


final class UpdateTests: XCTestCase {
    
    public final func testUpdateGameData() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let allGamesBundle = try CRUD.readAllGames(for: dbConnection)
            
            XCTAssertNotNil(allGamesBundle[.games])
            
            XCTAssertEqual(allGamesBundle[.games]!.count, 13)
            return .rollback
        }
    }
}
