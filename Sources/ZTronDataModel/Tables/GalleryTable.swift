import Foundation
import SQLite3
@preconcurrency import SQLite

/// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
/// - `PK(name, tool, tab, map, game)`
/// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// By naming convention design, `name` shouldn't contain any uppercased letter
///
/// Represents a gallery associated with a tool inside the tab, map and game specified by the  `tool`, `tab`, `map` and `game` fields.
///
/// In case of two galleries with the same in-game name under two different paths,  by design each of them should have a distinct identity, so that each of them
/// can be customized independently, and the disposal of the subhierarchy of a gallery is easier.
/// Iin this example:
///
///                                              Master
///                                         /              \
///         3,4-di-nitroxy-methyl-propane                     Octa-hydro-2,5-nitro-3,4,7-para-zokine
///        /                                                                                         \
///     formaldehyde                                                                                  formaldehyde
///
/// The two `formaldehyde` do not have the same identity, and their `name` cannot be the same. For example, call one `formaldehyde-3/4dnmp` and the other `formaldehyde-oh2n3pz`.
///
/// If conforming to this directive, up to date (29 Nov 2023) a gallery is guaranteed to be uniquely identified by the tuple (`name`, `game`, ` map`, `tool`);
/// though `tab`  is included in the primary key to guarantee referential integrity with respect to the table `TOOL`
///
/// - **CONSTRAINTS:**
///     - `position >= 0`
///
/// - **ACTIVE TRIGGERS:**
///     - `cascade_master_delete_from_gallery`: When deleting a gallery from `GALLERY`, this trigger removes all of its subgalleries from `GALLERY` and all of their
///     relationships with other galleries from `HAS_SUBGALLERY` recursively.
///
///         In other words, it removes from the database all the subhierarchy with root in the deleted gallery.
///
///         Requires to open a connection with `PRAGMA recursive_triggers = 1`.
///
///         Requires further testing.
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - `assetsImageName` is nullable, but all the leaf galleries in a gallery's subhierarchy should verify the condition `assetsImageName IS NOT NULL`, while
///     all the internal nodes, including the root, should verify `assetsImageName IS NULL`.
public final class Gallery: DBTableCreator {
    let tableName = "GALLERY"
    
    let nameColumn: SQLite.Expression<String>
    let positionColumn: SQLite.Expression<Int>
    let assetsImageNameColumn: SQLite.Expression<String?>
    let foreignKeys: Gallery.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.positionColumn = SQLite.Expression<Int>("position")
        self.nameColumn = SQLite.Expression<String>("name")
        self.foreignKeys = Gallery.ForeignKeys()
        self.assetsImageNameColumn = SQLite.Expression<String?>("assetsImageName")
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let toolModel = DomainModel.tool
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.nameColumn.template) TEXT NOT NULL,
                    \(self.positionColumn.template) INT NOT NULL CHECK(\(self.positionColumn.template) >= 0),
                    \(self.assetsImageNameColumn.template) TEXT,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.toolColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.nameColumn.template),
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ) REFERENCES \(toolModel.tableName)(
                        \(toolModel.nameColumn.template),
                        \(toolModel.foreignKeys.tabColumn.template),
                        \(toolModel.foreignKeys.mapColumn.template),
                        \(toolModel.foreignKeys.gameColumn.template)
                    ) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
    }
    
    final class ForeignKeys: Sendable {
        let toolColumn: SQLite.Expression<String>
        let tabColumn: SQLite.Expression<String>
        let mapColumn: SQLite.Expression<String>
        let gameColumn: SQLite.Expression<String>

        internal init() {
            self.toolColumn = SQLite.Expression<String>("tool")
            self.tabColumn = SQLite.Expression<String>("tab")
            self.mapColumn = SQLite.Expression<String>("map")
            self.gameColumn = SQLite.Expression<String>("game")
        }
    }
}
