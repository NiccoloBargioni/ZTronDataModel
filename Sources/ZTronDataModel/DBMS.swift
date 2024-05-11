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
            fatalError("\(self.DB_NAME) doesn't exist and can't be created")
        }

        do {
            try self.performSQLStatement(for: dbConnection, query: "BEGIN EXCLUSIVE TRANSACTION")
            
            try DomainModel.allTablesCreators.forEach { creator in
                try creator.makeTable(for: dbConnection)
            }
        } catch {
            try self.performSQLStatement(for: dbConnection, query: "ROLLBACK TRANSACTION")

            fatalError("Could not create DB schema")
        }
        
        try self.performSQLStatement(for: dbConnection, query: "COMMIT TRANSACTION")
    }
    
    #if DEBUG
    public static func mockInit() throws {
        guard let dbConnection = try? self.openSQLite3DB(caller: #function) else {
            fatalError("Could not open a connection to database \(self.DB_NAME)")
        }
        
        let statements = [
            """
            INSERT INTO "main"."STUDIO" ("name", "position", "assetsImageName") VALUES ('infinity ward', '0', 'placeholderStudio');
            """,
            """
            INSERT INTO "main"."GAME" ("name", "position", "assetsImageName", "studio") VALUES ('infinite warfare', '0', 'placeholderGame', 'infinity ward');
            """,
            """
            INSERT INTO "main"."MAP" ("name", "position", "assetsImageName", "game") VALUES ('spaceland', '0', 'placeholderMap', 'infinite warfare');
            """,
            """
            INSERT INTO "main"."TAB" ("name", "position", "iconName", "game", "map") VALUES ('music', '0', 'controller.fill', 'infinite warfare', 'spaceland');
            """,
            """
            INSERT INTO "main"."TOOL" ("name", "position", "assetsImageName", "tab", "game", "map") VALUES ('love the 80s', '0', 'placeholderTool', 'music', 'infinite warfare', 'spaceland');
            """
        ]
        try self.performSQLStatement(for: dbConnection, query: "BEGIN EXCLUSIVE TRANSACTION")
        
        try statements.forEach { statement in
            do {
                try performSQLStatement(for: dbConnection, query: statement)
            } catch {
                try self.performSQLStatement(for: dbConnection, query: "ROLLBACK TRANSACTION")
                sqlite3_close(dbConnection)
                fatalError("Could not perform the following query: \(statement)")
            }
        }
        
        try self.performSQLStatement(for: dbConnection, query: "COMMIT TRANSACTION")
        sqlite3_close(dbConnection)
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
    
    public static func transaction(_ caller: String = #function, _ body: @escaping (_ dbConnection: Connection) throws -> TransactionResult) throws {
        let dbConnection = try Self.openDB(caller: caller)
        var transactionBegun: Bool = false
        
        do {
            try dbConnection.run("BEGIN EXCLUSIVE TRANSACTION")
            transactionBegun = true
            
            let transactionResult = try body(dbConnection)
            
            switch transactionResult {
                case .commit:
                    try dbConnection.run("COMMIT TRANSACTION")
                
                case .rollback:
                    try dbConnection.run("ROLLBACK TRANSACTION")
            }
        } catch {
            if transactionBegun {
                try dbConnection.run("ROLLBACK TRANSACTION")
            }
            
            throw error
        }
    }
    
    public enum TransactionResult {
        case commit
        case rollback
    }
}

