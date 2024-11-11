import Foundation
import SQLite3
@preconcurrency import SQLite

/// - `IMAGE_VARIANT(master, slave, variant, bottomBarIcon, boundingFrameOriginX, boundingFrameOriginY, boundingFrameWidth, boundingFrameHeight, gallery, tool, tab, map, game)`
/// - `PK(slave, gallery, tool, tab, map, game)`
/// - `FK(slave, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Represents a master -> slave relationship between two images. An image for a specified tuple (`gallery`, `tool`, `tab`,  `map`, `game`)
/// can appear at most once as a slave, but many times as a master. `IMAGE_VARIANT` is a N:1 master-slave relationship. The 0..1 participation constraint is enforced via
/// the primary key of `IMAGE_VARIANT`.
///
/// - **CONSTRAINTS:**
///     None
///
/// - **ACTIVE TRIGGERS:**
///     - `master_referential_integrity_image_variant`: When adding a relationship between two images,
///     the `master` should respect the referential integrity constraint with respect to `IMAGE`,
///     and the `master` and `slave` should both belong to the same (`game`, ` map`,  `tab`, `tool`, `gallery`).
///     - `image_variant_bounding_frame_nullity_validation`:  The following set of attributes:
///
///         (``boundingFrameOriginX``, ``boundingFrameOriginY``, ``boundingFrameWidth``, ``boundingFrameHeight``)
///
///         Must be either all NULL or all NOT NULL. When all the values are not null, the following
///         constraints apply:
///
///           boundingFrameWidth BETWEEN 0 AND 1
///           boundingFrameHeight BETWEEN 0 AND 1
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     None
public final class ImageVariant: DBTableCreator {
    
    let tableName: String = "IMAGE_VARIANT"
    let masterColumn: SQLite.Expression<String>
    let slaveColumn: SQLite.Expression<String>
    let variantColumn: SQLite.Expression<String>
    let bottomBarIconColumn: SQLite.Expression<String>
    
    let boundingFrameOriginXColumn: SQLite.Expression<Double?>
    let boundingFrameOriginYColumn: SQLite.Expression<Double?>
    let boundingFrameWidthColumn: SQLite.Expression<Double?>
    let boundingFrameHeightColumn: SQLite.Expression<Double?>
    
    let foreignKeys: ImageVariant.ForeignKeys
    
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.masterColumn = SQLite.Expression<String>("master")
        self.slaveColumn = SQLite.Expression<String>("slave")
        self.variantColumn = SQLite.Expression<String>("variant")
        self.bottomBarIconColumn = SQLite.Expression<String>("bottomBarIcon")
        
        self.boundingFrameOriginXColumn = SQLite.Expression<Double?>("boundingFrameOriginX")
        self.boundingFrameOriginYColumn = SQLite.Expression<Double?>("boundingFrameoriginY")
        self.boundingFrameWidthColumn = SQLite.Expression<Double?>("boundingFrameWidth")
        self.boundingFrameHeightColumn = SQLite.Expression<Double?>("boundingFrameHeight")
        
        self.foreignKeys = ImageVariant.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let imageModel = DomainModel.image
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.masterColumn.template) TEXT NOT NULL,
                    \(self.slaveColumn.template) TEXT NOT NULL,
                    \(self.variantColumn.template) TEXT NOT NULL,
                    \(self.bottomBarIconColumn.template) TEXT NOT NULL,
                    \(self.boundingFrameOriginXColumn.template) REAL,
                    \(self.boundingFrameOriginYColumn.template) REAL,
                    \(self.boundingFrameWidthColumn.template) REAL,
                    \(self.boundingFrameHeightColumn.template) REAL,
                    \(self.foreignKeys.galleryColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.toolColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.slaveColumn.template),
                        \(self.foreignKeys.galleryColumn.template),
                        \(self.foreignKeys.toolColumn.template),
                        \(self.foreignKeys.tabColumn.template),
                        \(self.foreignKeys.mapColumn.template),
                        \(self.foreignKeys.gameColumn.template)
                    ),
                    FOREIGN KEY (
                        \(self.slaveColumn),
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
        try self.makeMasterReferentialIntegrityConstraintTrigger(for: dbConnection)
        try self.makeBoundingFrameNullityCheckTrigger(for: dbConnection)
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
