import Foundation
import SQLite3
import SQLite

/// - `TOOL(name, position, assetsImageName, tab, map, game)`
/// - `PK(name, tab, map, game)`
/// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// By naming convention design, `name` shouldn't contain any uppercased letter
///
/// Represents a game tool inside the tab, map and game specified by the `tab`, `map` and `game` fields.
///
/// Up to date (29 Nov 2023), each tool is uniquely identified by the subset of the primary key (`name`, `game`, `map`),
/// as there currently aren't any two tools with the same name under different (or even same) tabs for a specified game and map.
///
/// Though, by design the primary key contains `tab` to guarantee referential integrity with respect to the table `TAB`.
///
/// - **CONSTRAINTS:**
///     - `position >= 0`
///
/// - **ACTIVE TRIGGERS:**
///     None
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - The `position`s should be unique for each (tab, map, game); this constraint can be temporarily violated while sorting the tabs for a given (tab, game, map), but SQLite doesn't support `DISABLE TRIGGER`,
///         therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<tools.count}` interval, with no duplicates,  where `tools` is the array af all the tools
///     for a given (`game`, `map`, `tab`).
public class Tool: DBTableCreator {
    let tableName = "TOOL"
    
    let nameColumn: SQLite.Expression<String>
    let positionColumn: SQLite.Expression<Int>
    let assetsImageNameColumn: SQLite.Expression<String>
    let foreignKeys: Tool.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.nameColumn = SQLite.Expression<String>("name")
        self.positionColumn = SQLite.Expression<Int>("position")
        self.foreignKeys = Tool.ForeignKeys()
        self.assetsImageNameColumn = SQLite.Expression<String>("assetsImageName")
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let tabModel = DomainModel.tab
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.nameColumn.template) TEXT NOT NULL,
                    \(self.positionColumn.template) INT NOT NULL CHECK(\(self.positionColumn.template) >= 0),
                    \(self.assetsImageNameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.nameColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.gameColumn.template),
                        \(self.foreignKeys.mapColumn.template)
                    ) REFERENCES \(tabModel.tableName)(
                        \(tabModel.nameColumn.template),
                        \(tabModel.foreignKeys.gameColumn.template),
                        \(tabModel.foreignKeys.mapColumn.template)
                    ) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
    }
    
    class ForeignKeys {
        let tabColumn: SQLite.Expression<String>
        let mapColumn: SQLite.Expression<String>
        let gameColumn: SQLite.Expression<String>
        
        internal init() {
            self.tabColumn = SQLite.Expression<String>("tab")
            self.mapColumn = SQLite.Expression<String>("map")
            self.gameColumn = SQLite.Expression<String>("game")
        }
    }
}
