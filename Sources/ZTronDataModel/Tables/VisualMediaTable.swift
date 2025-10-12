import Foundation
import SQLite3
@preconcurrency import SQLite


/// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
/// - `PK(name, gallery, tool, tab, map, game)`
/// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
///
/// Situations may arise where images with the same apparent identity show up. By design choice, in those cases the repeating images actually have
/// each their own identity, to facilitate disposing the subhierarchies and customizing them independently. For example:
///
///
///                                              Master
///                                         /              \
///           3,4-di-nitroxy-methyl-propane                  Octa-hydro-2,5-nitro-3,4,7-para-zokine
///         /                                                                                        \
///     formaldehyde                                                                                 formaldehyde
///          |                                                                                            |
///      racing fuel                                                                                  racing fuel
///
/// The two `racing fuel` have different identities even though their `name` is the same, because  the two `formaldehyde` have different
/// identities.
///
/// Up to date 28 Nov. 2023, it is guaranteed that the subset of the primary key `name`, `gallery`, `tool`, `map`, `game` is unique
/// and `tab` is redundant. Though, it's necessary to guarantee referential integrity with respect to `GALLERY`.
///
/// - **CONSTRAINTS:**
///     - `position >= 0`
///
/// - **ACTIVE TRIGGERS:**
///     - `forbid_attaching_image_to_master`: Prevents an image from being associated with a gallery that's not a leaf of its hierarchy.
///
///         It collaborates with `forbid_master_containing_images` on ``HAS_SUBGALLERY`` to guarantee that images only appear at leaf gallery nodes.
///     - `cascade_master_delete_from_image`:  When deleting an image from `IMAGE`, it triggers the disposal of the whole subhierarchy rooted in the deleted image, and the
///     relationship between it and its master from `IMAGE_VARIANT`, if the deleted image was a slave.
///
///         Requires that the connection is opened with `PRAGMA recursive_triggers = 1`
///
///         Needs testing.
///     - `forbid_empty_extension_for_video`: Forces all entries that have `type` = `video` to have a non-empty extension, and all entries that have `type`=`image` to not provide an extension.
///
/// - **CONSTRAINTS NOT ENFORCED BY TRIGGERS:**
///     - The `position`s should be unique for each (gallery, tool, map, game, master); this constraint can be temporarily violated while sorting the images for a given (game, map, tool, gallery, master),
///     but SQLite doesn't support `DISABLE TRIGGER`, therefore it's the user's responsibility to maintain this invariant.
///     - `positions` should span the whole `{0..<images.count}` interval, with no duplicates,  where `images` is the array af all the images
///     for a given (`game`, `map`, `tab`, `tool`, `gallery`).
///    -  An image should only be allowed to appear at the deepest level of the gallery hierarchy. A sophisticated
///       check to validate that images can only appear at maximum depth across the whole hierarchy starting with the same gallery root, and that every leaf
///       gallery has at least one child image is recommended.
public final class VisualMedia: DBTableCreator {
    let tableName: String = "VISUAL_MEDIA"
    let typeColumn: SQLite.Expression<String>
    let extensionColumn: SQLite.Expression<String?>
    let nameColumn: SQLite.Expression<String>
    let descriptionColumn: SQLite.Expression<String>
    let positionColumn: SQLite.Expression<Int>
    let searchLabelColumn: SQLite.Expression<String?>
    let foreignKeys: VisualMedia.ForeignKeys
    let table: SQLite.Table
    
    internal init() {
        self.table = Table(tableName)
        self.typeColumn = SQLite.Expression<String>("type")
        self.extensionColumn = SQLite.Expression<String?>("extension")
        self.nameColumn = SQLite.Expression<String>("name")
        self.descriptionColumn = SQLite.Expression<String>("description")
        self.positionColumn = SQLite.Expression<Int>("position")
        self.searchLabelColumn = SQLite.Expression<String?>("searchLabel")
        self.foreignKeys = VisualMedia.ForeignKeys()
    }
    
    func makeTable(for dbConnection: OpaquePointer) throws {
        let galleryModel = DomainModel.gallery
        
        let tableCreationStatement =
            """
                CREATE TABLE IF NOT EXISTS \(self.tableName) (
                    \(self.typeColumn.template) TEXT NOT NULL,
                    \(self.extensionColumn.template) TEXT,
                    \(self.nameColumn.template) TEXT NOT NULL,
                    \(self.descriptionColumn.template) TEXT NOT NULL,
                    \(self.positionColumn.template) INT NOT NULL CHECK(\(self.positionColumn.template) >= 0),
                    \(self.searchLabelColumn.template) TEXT,
                    \(self.foreignKeys.galleryColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.tabColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.toolColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.mapColumn.template) TEXT NOT NULL,
                    \(self.foreignKeys.gameColumn.template) TEXT NOT NULL,
                    PRIMARY KEY (
                        \(self.nameColumn.template),
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
        try self.makeForbidAttachingImageToMasterTrigger(for: dbConnection)
        try self.makeCascadeMasterDeleteFromImageTrigger(for: dbConnection)
        try self.forbidEmptyExtensionForVideo(for: dbConnection)
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


public enum VisualMediaType: String, CaseIterable, Sendable {
    case video
    case image
}
