import Foundation
import SQLite3
@preconcurrency import SQLite

/// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
/// - `PK(image, gallery, tool, tab, map, game)`
/// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents the bounding circle for the image identified by the tuple (`image`, `gallery`, `tool`, `map`, `game`). The attribute `tab`
/// is included to guarantee the referential integrity constraint with respect to `IMAGE`.
///
/// This behaves as an optional attachment to an image.
///
/// - **CONSTRAINTS:**
///     - `opacity` BETWEEN 0 AND 1
///
/// - **ACTIVE TRIGGERS:**
///     - `bounding_circle_not_null_constraint`: `normalizedCenterX, normalizedCenterY`
///     must either be all NULL or all NOT NULL. In the second case the following constraints are enforced:
///
///         - boundingBoxOriginX BETWEEN 0 AND 1
///         - boundingBoxOriginY BETWEEN 0 AND 1
///         - boundingBoxWidth BETWEEN 0 AND 1
///         - boundingBoxHeight BETWEEN 0 AND 1
///
///     - `forbid_bounding_circle_on_video`: The visual media referenced by the `image` column must have type = 'image'
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     -   When an image doesn't have an outline but it has a bounding circle, `normalizedCenterX`, `normalizedCenterY`
///     and `idleDiameter` must not be NULL.
///     - When an image has an outline and a bounding circle, `normalizedCenterX`, `normalizedCenterY` must be nil, while
///     idleDiameter can be whatever.
public final class BoundingCircle: DBTableCreator {
    
    let tableName: String = "BOUNDING_CIRCLE"
    let colorHexColumn: SQLite.Expression<String>
    let isActiveColumn: SQLite.Expression<Bool>
    let opacityColumn: SQLite.Expression<Double>
    let idleDiameterColumn: SQLite.Expression<Double?>
    let normalizedCenterXColumn: SQLite.Expression<Double?>
    let normalizedCenterYColumn: SQLite.Expression<Double?>
    let foreignKeys: BoundingCircle.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.colorHexColumn = SQLite.Expression<String>("colorHex")
        self.isActiveColumn = SQLite.Expression<Bool>("isActive")
        self.opacityColumn = SQLite.Expression<Double>("opacity")
        self.idleDiameterColumn = SQLite.Expression<Double?>("idleDiameter")
        self.normalizedCenterXColumn = SQLite.Expression<Double?>("normalizedCenterX")
        self.normalizedCenterYColumn = SQLite.Expression<Double?>("normalizedCenterY")
        self.foreignKeys = BoundingCircle.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let imageModel = DomainModel.visualMedia
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.colorHexColumn.template) TEXT NOT NULL,
                    \(self.isActiveColumn.template) INTEGER NOT NULL,
                    \(self.opacityColumn.template) REAL NOT NULL CHECK (\(self.opacityColumn.template) BETWEEN 0 AND 1),
                    \(self.idleDiameterColumn.template) REAL,
                    \(self.normalizedCenterXColumn.template) REAL,
                    \(self.normalizedCenterYColumn.template) REAL,
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
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ) REFERENCES \(imageModel.tableName)(
                        \(imageModel.nameColumn.template),
                        \(imageModel.foreignKeys.galleryColumn.template),
                        \(imageModel.foreignKeys.toolColumn.template),
                        \(imageModel.foreignKeys.tabColumn.template),
                        \(imageModel.foreignKeys.mapColumn.template),
                        \(imageModel.foreignKeys.gameColumn.template)
                    ) ON DELETE CASCADE ON UPDATE CASCADE
                )
            """
        
        try DBMS.performSQLStatement(for: dbConnection, query: tableCreationStatement)
        try self.makeNotNullTrigger(for: dbConnection)
        try self.forbidBoundingCircleOnVideo(for: dbConnection)
    }
    
    final class ForeignKeys: Sendable {
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
