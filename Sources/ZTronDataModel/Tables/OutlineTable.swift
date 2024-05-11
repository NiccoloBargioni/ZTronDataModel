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
    let colorHexColumn: Expression<String>
    let isActiveColumn: Expression<Bool>
    let opacityColumn: Expression<Double>
    
    let boundingBoxOriginXColumn: Expression<Double>
    let boundingBoxOriginYColumn: Expression<Double>
    let boundingBoxWidthColumn: Expression<Double>
    let boundingBoxHeightColumn: Expression<Double>
    
    let foreignKeys: Outline.ForeignKeys
    
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.colorHexColumn = Expression<String>("colorHex")
        self.isActiveColumn = Expression<Bool>("isActive")
        self.opacityColumn = Expression<Double>("opacity")
        self.boundingBoxOriginXColumn = Expression<Double>("boundingBoxOriginX")
        self.boundingBoxOriginYColumn = Expression<Double>("boundingBoxOriginY")
        self.boundingBoxWidthColumn = Expression<Double>("boundingBoxWidth")
        self.boundingBoxHeightColumn = Expression<Double>("boundingBoxHeight")
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
        let imageColumn: Expression<String>
        let galleryColumn: Expression<String>
        let toolColumn: Expression<String>
        let tabColumn: Expression<String>
        let mapColumn: Expression<String>
        let gameColumn: Expression<String>
        
        internal init() {
            self.imageColumn = Expression<String>("image")
            self.galleryColumn = Expression<String>("gallery")
            self.toolColumn = Expression<String>("tool")
            self.tabColumn = Expression<String>("tab")
            self.mapColumn = Expression<String>("map")
            self.gameColumn = Expression<String>("game")
        }
    }
}
