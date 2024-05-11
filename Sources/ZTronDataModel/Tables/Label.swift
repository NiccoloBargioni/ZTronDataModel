import Foundation
import SQLite3
import SQLite

/// - `LABEL(label, isActive, icon, assetsImageName, textColorHex, backgroundColorHex, opacity, maxAABBOriginX, maxAABBOriginY, maxAABBWidth, maxAABBHeight, image, gallery, tool, tab, map, game)`
/// - `PK(label, image, gallery, tool, tab, map, game)`
/// - `FK(image, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a label associated to the image identified by the tuple (`image`, `gallery`, `tool`, `map`, `game`)
///
/// This behaves as an optional attachment to an image.
///
/// - **CONSTRAINTS:**
///     - `opacity` BETWEEN 0 AND 1
///
/// - **ACTIVE TRIGGERS:**
///     - `label_not_null_constraints`:  `maxAABBOriginX, maxAABBOriginY, maxAABBOriginWidth, maxAABBOriginHeight`
///     must either be all NULL or all NOT NULL. In the second case the following constraints are enforced:
///
///         - maxAABBOriginX BETWEEN 0 AND 1
///         - maxAABBOriginY BETWEEN 0 AND 1
///         - maxAABBWidth BETWEEN 0 AND 1
///         - maxAABBHeight BETWEEN 0 AND 1
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     None
public class Label: DBTableCreator {
    
    let tableName: String = "LABEL"
    let labelColumn: Expression<String>
    let isActiveColumn: Expression<Bool>
    let iconColumn: Expression<String?>
    let assetsImageNameColumn: Expression<String?>
    let textColorHexColumn: Expression<String>
    let backgroundColorHexColumn: Expression<String>
    let opacityColumn: Expression<Double>
    
    let maxAABBOriginXColumn: Expression<Double?>
    let maxAABBOriginYColumn: Expression<Double?>
    let maxAABBWidthColumn: Expression<Double?>
    let maxAABBHeightColumn: Expression<Double?>
    
    let foreignKeys: Label.ForeignKeys
    let table: SQLite.Table
    
    init() {
        self.table = Table(tableName)

        self.labelColumn = Expression<String>("label")
        self.isActiveColumn = Expression<Bool>("isActive")
        self.iconColumn = Expression<String?>("icon")
        self.assetsImageNameColumn = Expression<String?>("assetsImageName")
        self.textColorHexColumn = Expression<String>("textColorHex")
        self.backgroundColorHexColumn = Expression<String>("backgroundColorHex")
        self.opacityColumn = Expression<Double>("opacity")
        self.maxAABBOriginXColumn = Expression<Double?>("maxAABBOriginX")
        self.maxAABBOriginYColumn = Expression<Double?>("maxAABBOriginY")
        self.maxAABBWidthColumn = Expression<Double?>("maxAABBWidth")
        self.maxAABBHeightColumn = Expression<Double?>("maxAABBHeight")
        self.foreignKeys = Label.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let imageModel = DomainModel.image
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.labelColumn.template) TEXT NOT NULL,
                    \(self.isActiveColumn.template) INTEGER NOT NULL,
                    \(self.iconColumn.template) TEXT,
                    \(self.assetsImageNameColumn.template) TEXT,
                    \(self.textColorHexColumn.template) TEXT NOT NULL,
                    \(self.backgroundColorHexColumn.template) TEXT NOT NULL,
                    \(self.opacityColumn.template) REAL NOT NULL CHECK(\(self.opacityColumn.template) BETWEEN 0 AND 1),
                    \(self.maxAABBOriginXColumn.template) REAL,
                    \(self.maxAABBOriginYColumn.template) REAL,
                    \(self.maxAABBWidthColumn.template) REAL,
                    \(self.maxAABBHeightColumn.template) REAL,
                    \(self.foreignKeys.imageColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.galleryColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.toolColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.labelColumn.template),
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
                    ) REFERENCES \(imageModel.tableName) (
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
        try self.makeMaxAABBNotNullConstraint(for: dbConnection)
    }
    
    class ForeignKeys {
        let imageColumn: Expression<String>
        let galleryColumn: Expression<String>
        let tabColumn: Expression<String>
        let toolColumn: Expression<String>
        let mapColumn: Expression<String>
        let gameColumn: Expression<String>

        init() {
            self.imageColumn = Expression<String>("image")
            self.galleryColumn = Expression<String>("gallery")
            self.toolColumn = Expression<String>("tool")
            self.tabColumn = Expression<String>("tab")
            self.mapColumn = Expression<String>("map")
            self.gameColumn = Expression<String>("game")
        }
    }
}
