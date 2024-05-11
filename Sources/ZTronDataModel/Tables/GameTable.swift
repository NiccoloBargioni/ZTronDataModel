import Foundation
import SQLite3
import SQLite
    
/// - `GAME(name, position, assetsImageName, studio)`
/// - `PK(name)`
/// - `FK(studio) REFERENCES STUDIO(name) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a game developed by the studio specified in the `studio` field.
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
///     - The `position`s should be unique for each studio; this constraint can be temporarily violated while sorting the games for a given studio, but SQLite doesn't 
///     support `DISABLE TRIGGER`, therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<games.count}` interval, with no duplicates,  where `games` is the array
///     of all the games for a given `studio`.
public class Game: DBTableCreator {
    let tableName = "GAME"
    let nameColumn: Expression<String>
    let positionColumn: Expression<Int>
    let assetsImageNameColumn: Expression<String>
    let foreignKeys: Game.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.nameColumn = Expression<String>("name")
        self.positionColumn = Expression<Int>("position")
        self.assetsImageNameColumn = Expression<String>("assetsImageName")
        self.foreignKeys = Game.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let studioModel = DBMS.studio

        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.nameColumn.template) TEXT NOT NULL,
                    \(self.positionColumn.template) INT NOT NULL CHECK(\(self.positionColumn.template) >= 0),
                    \(self.assetsImageNameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.studioColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (\(self.nameColumn.template)),
                    FOREIGN KEY (\(self.foreignKeys.studioColumn.template)) REFERENCES \(studioModel.tableName)(\(studioModel.nameColumn.template)) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
    }
    
    class ForeignKeys {
        let studioColumn: Expression<String>
        
        internal init() {
            self.studioColumn = Expression<String>("studio")
        }
    }
}
