import Foundation
import SQLite
import SQLite3
@testable import ZTronDataModel

internal final class DBMSMockProvider: DBMSService {
    internal static let DB_NAME: String = "ztron_dump.sqlite3"
    
    private init() {  }
    
    internal static func openDB(caller: String) throws -> SQLite.Connection {
        guard let db = Self.getDBPath() else { fatalError("Unable to find the database \(Self.DB_NAME) at \(String(describing: Self.getDBPath()))") }
        return try DBMSMockProvider.openDB(path: db, caller: #function)
    }
    
    
    internal static func openSQLite3DB(caller: String) throws -> OpaquePointer? {
        guard let db = Self.getDBPath() else { fatalError("Unable to find the database \(Self.DB_NAME) at \(String(describing: Self.getDBPath()))") }
        return try DBMSMockProvider.openSQLite3DB(path: db, caller: #function)
    }

    internal static func getDBPath() -> String? {
        let bundle = Bundle.module

        guard let dbPath = bundle.path(forResource: "ztron_dump", ofType: "sqlite3") else {
            fatalError("Could not find ztron_dump.sqlite3 in the test bundle.")
        }

        return dbPath
    }
}
