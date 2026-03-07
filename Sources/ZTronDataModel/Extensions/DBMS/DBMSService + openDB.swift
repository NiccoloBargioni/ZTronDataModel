import Foundation
import SQLite3
import SQLite

extension DBMSService {
    internal static func openDB(dbName: String, caller: String) throws -> Connection {
        let documentsDirPath = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        guard let documentsDirPath = documentsDirPath else {
            throw SQLQueryError.documentsPathNotFoundException(reason: "documentDirectory not found in userDomainMask")
        }

        let dbURL = documentsDirPath.appendingPathComponent(dbName).relativePath
        
        do {
            print("dbConnection URL: \(dbURL) from \(caller)")
            let dbConnection = try Connection(dbURL)
            try dbConnection.run("PRAGMA recursive_triggers = 1")
            try dbConnection.run("PRAGMA foreign_keys = 1")
            return dbConnection
        } catch {
            throw SQLQueryError.ioException(reason: "Could not open db at \(dbURL)")
        }
    }
    
    
    internal static func openDB(path: String, caller: String) throws -> Connection {
        
        do {
            print("dbConnection URL: \(path) from \(caller)")
            let dbConnection = try Connection(path)
            try dbConnection.run("PRAGMA recursive_triggers = 1")
            try dbConnection.run("PRAGMA foreign_keys = 1")
            return dbConnection
        } catch {
            throw SQLQueryError.ioException(reason: "Could not open db at \(path)")
        }
    }
    
    
    internal static func openSQLite3DB(dbName: String, caller: String) throws -> OpaquePointer? {
        let documentsDirPath = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        guard let documentsDirPath = documentsDirPath else {
            throw SQLQueryError.documentsPathNotFoundException(reason: "documentDirectory not found in userDomainMask")
        }

        var db: OpaquePointer?
        let dbURL = documentsDirPath.appendingPathComponent(dbName).relativePath
        
        print("dbConnection URL: \(dbURL) from \(caller)")
        
        if sqlite3_open(dbURL, &db) == SQLITE_OK {
            if let db = db {
                try self.performSQLStatement(for: db, query: "PRAGMA foreign_keys = 1")
                try self.performSQLStatement(for: db, query: "PRAGMA recursive_triggers = 1")
            }
            return db
        } else {
            throw SQLQueryError.ioException(reason: "Unable to open SQLite3 db for \(dbURL)")
        }
    }
    
    
    internal static func openSQLite3DB(path: String, caller: String) throws -> OpaquePointer? {
        var db: OpaquePointer?
        let dbURL = path
        
        print("dbConnection URL: \(dbURL) from \(caller)")
        
        if sqlite3_open(dbURL, &db) == SQLITE_OK {
            if let db = db {
                try self.performSQLStatement(for: db, query: "PRAGMA foreign_keys = 1")
                try self.performSQLStatement(for: db, query: "PRAGMA recursive_triggers = 1")
            }
            return db
        } else {
            throw SQLQueryError.ioException(reason: "Unable to open SQLite3 db for \(dbURL)")
        }
    }
}
