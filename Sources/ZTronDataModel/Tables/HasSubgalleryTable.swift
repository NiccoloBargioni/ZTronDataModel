import Foundation
import SQLite3
import SQLite


/// - `HAS_SUBGALLERY(master, slave, tool, tab, map, game)`
/// - `PK(slave, tool, tab, map, game)`
/// - `FK(slave, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a master -> slave relationship between two galleries. A gallery for a specified tuple (`tool`, ` map`,  `game`)
/// can appear at most once as a slave, but many times as a master. `HAS_SUBGALLERY` is a N:1 master-slave relationship. The 0..1 participation constraint is enforced via
/// the primary key of `HAS_SUBGALLERY`.
///
/// - **CONSTRAINTS:**
///     None 
///
/// - **ACTIVE TRIGGERS:**
///     - `master_referential_integrity_subgallery`: When adding a relationship between two galleries, the `master` should respect the referential integrity constraint with
///     respect to `GALLERY`, and the `master` and `slave` should both belong to the same (`game`, ` map`, `tool`).
///     - `forbid_master_containing_images`: Before insertion on this table, this trigger asserts that `master` doesn't have any associated image with it, to guarantee that images can only appear under leaf galleries.
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - The `position`s should be unique for each (master, tool, map, game); this constraint can be temporarily violated while sorting the subgalleries for a given (game, map, tool, master),
///         but SQLite doesn't support `DISABLE TRIGGER`, therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<subgalleries.count}` interval, with no duplicates,  where `subgalleries` is the array af all the
///     subgalleries for a given (`game`, `map`, `tab`, `tool`, `master`). This should be true for each `master`.
public class HasSubgallery: DBTableCreator {
    let tableName = "HAS_SUBGALLERY"
    let masterColumn: Expression<String>
    let slaveColumn: Expression<String>
    let foreignKeys: HasSubgallery.ForeignKeys
    
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.masterColumn = Expression<String>("master")
        self.slaveColumn = Expression<String>("slave")
        self.foreignKeys = HasSubgallery.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let galleryModel = DomainModel.gallery
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.masterColumn.template) TEXT NOT NULL,
                    \(self.slaveColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.toolColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.slaveColumn.template),
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.slaveColumn.template),
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ) REFERENCES \(galleryModel.tableName)(
                        \(galleryModel.nameColumn.template),
                        \(galleryModel.foreignKeys.toolColumn.template),
                        \(galleryModel.foreignKeys.tabColumn.template),
                        \(galleryModel.foreignKeys.mapColumn.template),
                        \(galleryModel.foreignKeys.gameColumn.template)
                    ) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
        try self.makeTriggers(for: dbConnection)
    }
    
    private func makeTriggers(for dbConnection: OpaquePointer) throws {
        try makeMasterReferentialIntegrityConstraintTrigger(for: dbConnection)
        try makeCascadeMasterDeleteFromGalleryTrigger(for: dbConnection)
        try makeForbidMasterContainingImagesTrigger(for: dbConnection)
    }
    
    class ForeignKeys {
        let toolColumn: Expression<String>
        let tabColumn: Expression<String>
        let mapColumn: Expression<String>
        let gameColumn: Expression<String>

        internal init() {
            self.toolColumn = Expression<String>("tool")
            self.tabColumn = Expression<String>("tab")
            self.mapColumn = Expression<String>("map")
            self.gameColumn = Expression<String>("game")

        }
    }
}

