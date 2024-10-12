import Foundation
import SQLite3
import SQLite
    
/// - `MAP(name, position, assetsImageName, game)`
/// - `PK(name, game)`
/// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a map for the game specified by the `game` field. A map and its remake have different identities since they have the same `name` but different `game`.
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
///     - The `position`s should be unique for each game; this constraint can be temporarily violated while sorting the maps for a given game, but SQLite doesn't support `DISABLE TRIGGER`,
///         therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<maps.count}` interval, with no duplicates,  where `maps` is the array af all the maps
///     for a given `game`.
public class Map: DBTableCreator {
    let tableName = "MAP"

    let nameColumn: SQLite.Expression<String>
    let positionColumn: SQLite.Expression<Int>
    let assetsImageNameColumn: SQLite.Expression<String>
    let foreignKeys: Map.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.nameColumn = SQLite.Expression<String>("name")
        self.positionColumn = SQLite.Expression<Int>("position")
        self.assetsImageNameColumn = SQLite.Expression<String>("assetsImageName")
        self.foreignKeys = Map.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let gameModel = DomainModel.game

        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.nameColumn.template) TEXT NOT NULL,
                    \(self.positionColumn.template) INT NOT NULL CHECK(\(self.positionColumn.template) >= 0),
                    \(self.assetsImageNameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.nameColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (\(self.foreignKeys.gameColumn.template)) REFERENCES \(gameModel.tableName)(\(gameModel.nameColumn.template)) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
       
    }
    
    class ForeignKeys {
        let gameColumn: SQLite.Expression<String>
        
        internal init() {
            self.gameColumn = SQLite.Expression<String>("game")
        }
    }
}

