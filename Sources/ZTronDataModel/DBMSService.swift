import Foundation
import SQLite
import SQLite3

public protocol DBMSService {
    static var DB_NAME: String { get }
    
    static func openDB(caller: String) throws -> Connection
    static func openSQLite3DB(caller: String) throws -> OpaquePointer?
}

public enum TransactionResult {
    case commit
    case rollback
}


public extension DBMSService {
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
    
    
    static func make() throws {
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
    
    
    /// - Important: If an exception happens during a transaction, the transaction rolls back and rethrows.
    static func transaction(
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
}
