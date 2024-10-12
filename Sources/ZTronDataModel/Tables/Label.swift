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
    let labelColumn: SQLite.Expression<String>
    let isActiveColumn: SQLite.Expression<Bool>
    let iconColumn: SQLite.Expression<String?>
    let assetsImageNameColumn: SQLite.Expression<String?>
    let textColorHexColumn: SQLite.Expression<String>
    let backgroundColorHexColumn: SQLite.Expression<String>
    let opacityColumn: SQLite.Expression<Double>
    
    let maxAABBOriginXColumn: SQLite.Expression<Double?>
    let maxAABBOriginYColumn: SQLite.Expression<Double?>
    let maxAABBWidthColumn: SQLite.Expression<Double?>
    let maxAABBHeightColumn: SQLite.Expression<Double?>
    
    let foreignKeys: Label.ForeignKeys
    let table: SQLite.Table
    
    init() {
        self.table = Table(tableName)

        self.labelColumn = SQLite.Expression<String>("label")
        self.isActiveColumn = SQLite.Expression<Bool>("isActive")
        self.iconColumn = SQLite.Expression<String?>("icon")
        self.assetsImageNameColumn = SQLite.Expression<String?>("assetsImageName")
        self.textColorHexColumn = SQLite.Expression<String>("textColorHex")
        self.backgroundColorHexColumn = SQLite.Expression<String>("backgroundColorHex")
        self.opacityColumn = SQLite.Expression<Double>("opacity")
        self.maxAABBOriginXColumn = SQLite.Expression<Double?>("maxAABBOriginX")
        self.maxAABBOriginYColumn = SQLite.Expression<Double?>("maxAABBOriginY")
        self.maxAABBWidthColumn = SQLite.Expression<Double?>("maxAABBWidth")
        self.maxAABBHeightColumn = SQLite.Expression<Double?>("maxAABBHeight")
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
        let imageColumn: SQLite.Expression<String>
        let galleryColumn: SQLite.Expression<String>
        let tabColumn: SQLite.Expression<String>
        let toolColumn: SQLite.Expression<String>
        let mapColumn: SQLite.Expression<String>
        let gameColumn: SQLite.Expression<String>

        init() {
            self.imageColumn = SQLite.Expression<String>("image")
            self.galleryColumn = SQLite.Expression<String>("gallery")
            self.toolColumn = SQLite.Expression<String>("tool")
            self.tabColumn = SQLite.Expression<String>("tab")
            self.mapColumn = SQLite.Expression<String>("map")
            self.gameColumn = SQLite.Expression<String>("game")
        }
    }
}
