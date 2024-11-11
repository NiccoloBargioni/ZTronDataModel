import Foundation
import SQLite3
@preconcurrency import SQLite

/// - `GALLERY_SEARCH_TOKEN(title, icon, iconColorHex, gallery, tool, tab, map, game)`
/// - `PK(gallery, tool, tab, map, game)`
/// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a chip for the search inside subgalleries, with an icon, icon color and a text. Not every gallery has a search token, but those who have must have at most one.
/// This constraint is already enforced by the primary key, and this table behaves as an optional addition to a gallery.
///
/// Up to date 29 Nov 2023, a search token is uniquely identified by the subset of the primary key (`gallery`, `tool`, `map`, `game`).
/// Though, `tab` is included in the primary key to guarantee referential integrity with respect to the table `GALLERY`.
///
/// - **CONSTRAINTS:**
///     None
///
/// - **ACTIVE TRIGGERS:**
///     None
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - `icon` must be the name of an SFSymbol or systemImage.
public final class GallerySearchToken: DBTableCreator {
    let tableName = "GALLERY_SEARCH_TOKEN"
    let titleColumn: SQLite.Expression<String>
    let iconColumn: SQLite.Expression<String>
    let iconColorHexColumn: SQLite.Expression<String>
    let foreignKeys: GallerySearchToken.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.titleColumn = SQLite.Expression<String>("title")
        self.iconColumn = SQLite.Expression<String>("icon")
        self.iconColorHexColumn = SQLite.Expression<String>("iconColorHex")
        self.foreignKeys = GallerySearchToken.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let galleryModel = DomainModel.gallery
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.titleColumn.template) TEXT NOT NULL,
                    \(self.iconColumn.template) TEXT NOT NULL,
                    \(self.iconColorHexColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.galleryColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.toolColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.foreignKeys.galleryColumn.template),
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.foreignKeys.galleryColumn.template),
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
    }
    
    final class ForeignKeys: Sendable {
        let galleryColumn: SQLite.Expression<String>
        let toolColumn: SQLite.Expression<String>
        let tabColumn: SQLite.Expression<String>
        let mapColumn: SQLite.Expression<String>
        let gameColumn: SQLite.Expression<String>

        
        internal init() {
            self.galleryColumn = SQLite.Expression<String>("gallery")
            self.toolColumn = SQLite.Expression<String>("tool")
            self.tabColumn = SQLite.Expression<String>("tab")
            self.mapColumn = SQLite.Expression<String>("map")
            self.gameColumn = SQLite.Expression<String>("game")
        }

    }
}
