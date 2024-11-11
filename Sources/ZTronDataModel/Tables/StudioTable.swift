import Foundation
import SQLite3
@preconcurrency import SQLite

/// - `STUDIO(name, position, assetsImageName)`
/// - `PK(name)`
///
/// Represents the developers studios in the Activision domain.
///
/// By naming convention design, the `name` field should contain no uppercased letter.
///
/// - **CONSTRAINTS:**
///     - `position >= 0`
///
/// - **ACTIVE TRIGGERS:**
///     None
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - The `position`s should be unique; this constraint can be temporarily violated while sorting the studios, but SQLite doesn't support `DISABLE TRIGGER`,
///         therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<studios.count}` interval, with no duplicates.
public final class Studio: DBTableCreator {
    
    let tableName: String = "STUDIO"
    
    let nameColumn: SQLite.Expression<String>
    let positionColumn: SQLite.Expression<Int>
    let assetsImageNameColumn: SQLite.Expression<String>
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(self.tableName)
        self.nameColumn = SQLite.Expression<String>("name")
        self.assetsImageNameColumn = SQLite.Expression<String>("assetsImageName")
        self.positionColumn = SQLite.Expression<Int>("position")
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.nameColumn.template) TEXT NOT NULL,
                    \(self.positionColumn.template) INT NOT NULL CHECK(\(self.positionColumn.template)>=0),
                    \(self.assetsImageNameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (\(self.nameColumn.template))
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
    }
    
}
