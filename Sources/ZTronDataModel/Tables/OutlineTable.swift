import Foundation
import SQLite3
import SQLite

/// - `OUTLINE(colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
/// - `PK(image, gallery, tool, tab, map, game)`
/// - `FK(image, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents the outline for the image identified by the tuple (`image`, `gallery`, `tool`, `map`, `game`). The attribute `tab` is
/// included to guarantee the referential integrity constraint with respect to ``IMAGE``.
///
/// This behaves as an optional attachment to an image.
///
/// - **CONSTRAINTS:**
///     - `opacity BETWEEN 0 AND 1`
///     - `boundingBoxOriginX BETWEEN 0 AND 1`
///     - `boundingBoxOriginY BETWEEN 0 AND 1`
///     - `boundingBoxWidth BETWEEN 0 AND 1`
///     - `boundingBoxHeight BETWEEN 0 AND 1``
///
/// - **ACTIVE TRIGGERS:**
///     None
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     None
public class Outline: DBTableCreator {
    
    let tableName: String = "OUTLINE"
    let colorHexColumn: SQLite.Expression<String>
    let isActiveColumn: SQLite.Expression<Bool>
    let opacityColumn: SQLite.Expression<Double>
    
    let boundingBoxOriginXColumn: SQLite.Expression<Double>
    let boundingBoxOriginYColumn: SQLite.Expression<Double>
    let boundingBoxWidthColumn: SQLite.Expression<Double>
    let boundingBoxHeightColumn: SQLite.Expression<Double>
    
    let foreignKeys: Outline.ForeignKeys
    
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.colorHexColumn = SQLite.Expression<String>("colorHex")
        self.isActiveColumn = SQLite.Expression<Bool>("isActive")
        self.opacityColumn = SQLite.Expression<Double>("opacity")
        self.boundingBoxOriginXColumn = SQLite.Expression<Double>("boundingBoxOriginX")
        self.boundingBoxOriginYColumn = SQLite.Expression<Double>("boundingBoxOriginY")
        self.boundingBoxWidthColumn = SQLite.Expression<Double>("boundingBoxWidth")
        self.boundingBoxHeightColumn = SQLite.Expression<Double>("boundingBoxHeight")
        self.foreignKeys = Outline.ForeignKeys()
    }
    
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let imageModel = DomainModel.image
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.colorHexColumn.template) TEXT NOT NULL,
                    \(self.isActiveColumn.template) INTEGER NOT NULL,
                    \(self.opacityColumn.template) REAL NOT NULL CHECK(\(self.opacityColumn.template) BETWEEN 0 AND 1),
                    \(self.boundingBoxOriginXColumn.template) REAL NOT NULL CHECK(\(self.boundingBoxOriginXColumn.template) BETWEEN 0 AND 1),
                    \(self.boundingBoxOriginYColumn.template) REAL NOT NULL CHECK(\(self.boundingBoxOriginYColumn.template) BETWEEN 0 AND 1),
                    \(self.boundingBoxWidthColumn.template) REAL NOT NULL CHECK(\(self.boundingBoxWidthColumn.template) BETWEEN 0 AND 1),
                    \(self.boundingBoxHeightColumn.template) REAL NOT NULL CHECK(\(self.boundingBoxWidthColumn.template) BETWEEN 0 AND 1),
                    \(self.foreignKeys.imageColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.galleryColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.toolColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.foreignKeys.imageColumn.template),
                        \(self.foreignKeys.galleryColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.foreignKeys.imageColumn.template),
                        \(self.foreignKeys.galleryColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ) REFERENCES \(imageModel.tableName)(
                        \(imageModel.nameColumn.template),
                        \(imageModel.foreignKeys.galleryColumn.template),
                        \(imageModel.foreignKeys.tabColumn.template),
                        \(imageModel.foreignKeys.toolColumn.template),
                        \(imageModel.foreignKeys.mapColumn.template),
                        \(imageModel.foreignKeys.gameColumn.template)
                    ) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
    }
    
    class ForeignKeys {
        let imageColumn: SQLite.Expression<String>
        let galleryColumn: SQLite.Expression<String>
        let toolColumn: SQLite.Expression<String>
        let tabColumn: SQLite.Expression<String>
        let mapColumn: SQLite.Expression<String>
        let gameColumn: SQLite.Expression<String>
        
        internal init() {
            self.imageColumn = SQLite.Expression<String>("image")
            self.galleryColumn = SQLite.Expression<String>("gallery")
            self.toolColumn = SQLite.Expression<String>("tool")
            self.tabColumn = SQLite.Expression<String>("tab")
            self.mapColumn = SQLite.Expression<String>("map")
            self.gameColumn = SQLite.Expression<String>("game")
        }
    }
}
