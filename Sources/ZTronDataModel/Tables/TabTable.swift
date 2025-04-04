import Foundation
import SQLite3
@preconcurrency import SQLite

/// - `TAB(name, position, iconName, map, game)`
/// - `PK(name, map, game)`
/// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a game tab for a map and game specified by `map` and `game` fields.
///
/// By naming convention design, `name` shouldn't contain any uppercased letter.
///
/// - **CONSTRAINTS:**
///     - `position >= 0`
///
/// - **ACTIVE TRIGGERS:**
///     None
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - The `position`s should be unique for each (map, game); this constraint can be temporarily violated while sorting the tabs for a given (game, map), but SQLite doesn't support `DISABLE TRIGGER`,
///         therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<tabs.count}` interval, with no duplicates,  where `tabs` is the array af all the tabs
///     for a given (`game`, `map`).
public final class Tab: DBTableCreator {
    let tableName = "TAB"
    
    let nameColumn: SQLite.Expression<String>
    let positionColumn: SQLite.Expression<Int>
    let iconNameColumn: SQLite.Expression<String>
    let foreignKeys: Tab.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.nameColumn = SQLite.Expression<String>("name")
        self.positionColumn = SQLite.Expression<Int>("position")
        self.iconNameColumn = SQLite.Expression<String>("iconName")
        self.foreignKeys = Tab.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let mapModel = DomainModel.map
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.nameColumn.template) TEXT NOT NULL,
                    \(self.positionColumn.template) INT NOT NULL CHECK(\(self.positionColumn.template) >= 0),
                    \(self.iconNameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.nameColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.foreignKeys.gameColumn.template),
                        \(self.foreignKeys.mapColumn.template)
                    ) REFERENCES \(mapModel.tableName)(
                        \(mapModel.foreignKeys.gameColumn.template),
                        \(mapModel.nameColumn.template)
                    ) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
    }
    
    final class ForeignKeys: Sendable {
        let mapColumn: SQLite.Expression<String>
        let gameColumn: SQLite.Expression<String>
        
        internal init() {
            self.mapColumn = SQLite.Expression<String>("map")
            self.gameColumn = SQLite.Expression<String>("game")
        }
    }
}
