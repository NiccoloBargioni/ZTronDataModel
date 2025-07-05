import Foundation
import SQLite3
import SQLite

public class DBMS {
    static public let dbSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
        
    private init() { }

    public static func openDB(caller: String) throws -> Connection {
        return try self.openDB(dbName: self.DB_NAME, caller: caller)
    }
    
    public static func openSQLite3DB(caller: String) throws -> OpaquePointer? {
        return try self.openSQLite3DB(dbName: self.DB_NAME, caller: caller)
    }

    static func tableExists(_ tableName: String, in db: Connection) -> Bool {
        let table = Table(tableName)

        do {
            let _ = try db.scalar(table.exists)
            return true
        } catch {
            return false
        }
    }

    public static func make() throws {
        guard let dbConnection = try? self.openSQLite3DB(caller: #function) else {
            throw SQLQueryError.ioException(reason: "Could not open SQLite3 db connection")
        }

        do {
            try self.performSQLStatement(for: dbConnection, query: "BEGIN EXCLUSIVE TRANSACTION")
            
            try DomainModel.allTablesCreators.forEach { creator in
                try creator.makeTable(for: dbConnection)
            }
        } catch {
            try self.performSQLStatement(for: dbConnection, query: "ROLLBACK TRANSACTION")
            throw SQLQueryError.tableCreationError(reason: "Could not create tables")
        }
        
        try self.performSQLStatement(for: dbConnection, query: "COMMIT TRANSACTION")
    }
    
    #if DEBUG
    public static func mockInit(or: OnConflict = .abort) throws {
        guard let dbConnection = try? self.openSQLite3DB(caller: #function) else {
            throw SQLQueryError.ioException(reason: "Could not open SQLite3 db connection to \(Self.DB_NAME)")
        }
        
        defer {
            sqlite3_close(dbConnection)
        }
        
        let statements = [
            """
            INSERT OR \(or.rawValue) INTO "main"."STUDIO" ("name", "position", "assetsImageName") VALUES ('infinity ward', '0', 'placeholderStudio');
            """,
            """
            INSERT OR \(or.rawValue) INTO "main"."GAME" ("name", "position", "assetsImageName", "studio") VALUES ('infinite warfare', '0', 'placeholderGame', 'infinity ward');
            """,
            """
            INSERT OR \(or.rawValue) INTO "main"."MAP" ("name", "position", "assetsImageName", "game") VALUES ('spaceland', '0', 'placeholderMap', 'infinite warfare');
            """,
            """
            INSERT OR \(or.rawValue) INTO "main"."TAB" ("name", "position", "iconName", "game", "map") VALUES ('music', '0', 'controller.fill', 'infinite warfare', 'spaceland');
            """,
            """
            INSERT OR \(or.rawValue) INTO "main"."TOOL" ("name", "position", "assetsImageName", "tab", "game", "map") VALUES ('love the 80s', '0', 'placeholderTool', 'music', 'infinite warfare', 'spaceland');
            """
        ]
        
        try self.performSQLStatement(for: dbConnection, query: "BEGIN EXCLUSIVE TRANSACTION")
        
        try statements.forEach { statement in
            do {
                try performSQLStatement(for: dbConnection, query: statement)
            } catch {
                do {
                    try self.performSQLStatement(for: dbConnection, query: "ROLLBACK TRANSACTION")
                } catch {
                    if or != .rollback {
                        throw error
                    }
                }
            }
        }
        
        do {
            try self.performSQLStatement(for: dbConnection, query: "COMMIT TRANSACTION")
        } catch {
            if or != .rollback {
                throw error
            }
        }
    }
    #endif

    static func performSQLStatement(for dbConnection: OpaquePointer, query: String) throws {
        var statement: OpaquePointer?
                
        if sqlite3_prepare_v2(dbConnection, query, -1, &statement, nil) == SQLITE_OK {
            let step = sqlite3_step(statement)
            if step != SQLITE_DONE {
                sqlite3_finalize(statement)
                throw SQLQueryError.genericError(reason: "Could perform the following statement: \(query); step: \(step)")
            } else {
                sqlite3_finalize(statement)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection))
            sqlite3_finalize(statement)
            throw SQLQueryError.genericError(reason: "Error preparing statement: \(errorMessage)")
        }
    }
    
    static func performCountStatement(for dbConnection: OpaquePointer, query: String) throws -> Int {
        var statement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbConnection, query, -1, &statement, nil) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection))
            sqlite3_finalize(statement)
            throw SQLQueryError.creationStatementPreparationError(reason: errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection))
            sqlite3_finalize(statement)
            throw SQLQueryError.ioException(reason: errorMessage)
        }

        let count = Int(sqlite3_column_int(statement, 0))
        sqlite3_finalize(statement)

        return count
    }
    
    /// - Important: If an exception happens during a transaction, the transaction rolls back and rethrows.
    public static func transaction(
        _ caller: String = #function,
        _ body: @escaping (_ dbConnection: Connection) throws -> TransactionResult,
        _ didCommit: (() -> Void)? = nil,
        _ didRollback: (() -> Void)? = nil
    ) throws {
        let dbConnection = try Self.openDB(caller: caller)
        var transactionBegun: Bool = false
        
        do {
            try dbConnection.run("BEGIN EXCLUSIVE TRANSACTION")
            transactionBegun = true
            
            let transactionResult = try body(dbConnection)
            
            switch transactionResult {
                case .commit:
                    try dbConnection.run("COMMIT TRANSACTION")
                    didCommit?()
                
                case .rollback:
                    try dbConnection.run("ROLLBACK TRANSACTION")
                    didRollback?()
            }
        } catch {
            if transactionBegun {
                try dbConnection.run("ROLLBACK TRANSACTION")
                didRollback?()
            }
            
            throw error
        }
    }
    
    public enum TransactionResult {
        case commit
        case rollback
    }
}

