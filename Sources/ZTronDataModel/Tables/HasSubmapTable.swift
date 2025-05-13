import Foundation
import SQLite3
@preconcurrency import SQLite


/// - `HAS_SUBMAP(master, slave, game)`
/// - `PK(slave, game)`
/// - `FK(slave, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a master -> slave relationship between two maps. A map for a specified `game`
/// can appear at most once as a slave, but many times as a master. `HAS_SUBMAP` is a N:1 master-slave relationship. The 0..1 participation constraint is enforced via
/// the primary key of `HAS_SUBMAP`.
///
/// - **CONSTRAINTS:**
///     None
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - The `position`s should be unique for each (master, tool, map, game); this constraint can be temporarily violated while sorting the submaps for a given map,
///         but SQLite doesn't support `DISABLE TRIGGER`, therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<submaps.count}` interval, with no duplicates,  where `submaps` is the array af all the
///     submaps for a given `master`. This should be true for each `ßmaster`.
public final class HasSubmapTable: DBTableCreator {
    let tableName = "HAS_SUBMAP"
    let masterColumn: SQLite.Expression<String>
    let slaveColumn: SQLite.Expression<String>
    let foreignKeys: Map.ForeignKeys
    
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.masterColumn = SQLite.Expression<String>("master")
        self.slaveColumn = SQLite.Expression<String>("slave")
        self.foreignKeys = Map.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.masterColumn.template) TEXT NOT NULL,
                    \(self.slaveColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.slaveColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.slaveColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ) REFERENCES \(DomainModel.map.tableName)(
                        \(DomainModel.map.nameColumn.template),
                        \(DomainModel.map.foreignKeys.gameColumn.template)
                    ) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
    }
}

