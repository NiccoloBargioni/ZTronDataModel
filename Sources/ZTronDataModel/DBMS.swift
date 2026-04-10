import Foundation
import SQLite3
import SQLite

public class DBMS: DBMSService {
    public static let DB_NAME: String = "ztron.sqlite3"
    
    private init() { }
    
    
    public static func openDB(caller: String) throws -> Connection {
        return try Self.openDB(dbName: Self.DB_NAME, caller: caller)
    }
    
    
    public static func openSQLite3DB(caller: String) throws -> OpaquePointer? {
        return try Self.openSQLite3DB(dbName: Self.DB_NAME, caller: caller)
    }
}

