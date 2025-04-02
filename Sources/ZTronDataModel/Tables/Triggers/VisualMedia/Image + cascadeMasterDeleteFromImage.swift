import Foundation

extension VisualMedia {
    
    /// When a row from `VISUAL MEDIA` is deleted, the matching gallery might or might not be a `slave`, a `master`, or both.
    ///
    /// -  if the deleted image was a `slave`, there exists a single `image` that could be its `master`, by design, and the relationship must be disposed.
    /// - if the deleted image was a `master`, it might have been a `master` for a whole subhierarchy, whose `slave`s need to be removed from `IMAGE_VARIANT`
    ///     and from `IMAGE`.
    ///
    /// `IMAGE_VARIANT` carries an explicit referential integrity constraint on its attributes (`slave`, `tool`, `tab`, `game`, `map`) referencing `GALLERY`
    /// with an `ON DELETE CASCADE` clause.
    ///
    /// This entails that whenever an image that's a `slave` is deleted from `IMAGE`, all the rows where it appears as a `slave` (image variants) get automatically removed.
    /// Though, this doesn't automatically fire the removal of all of its subhierarchy.
    ///
    /// To fire it, this trigger deletes from `IMAGE` all the entries where the deleted image appeared as a `master`
    ///
    /// - Example:
    /// Consider the following `IMAGE` table:
    /// ```
    ///     ('RITR_BelowTableFirstFloor', 'yadayada', 0, 'a search label', 'master', 'puppet strings', 'music', 'rave in the redwoods', 'infinite warfare');
    ///     ('RITR_BelowTableFirstFloorZoom', 'yadayada', 0, 'a search label', 'master', 'puppet strings', 'music', 'rave in the redwoods', 'infinite warfare');
    ///     ('RITR_BelowTableFirstFloorRave', 'yadayada', 0, 'a search label', 'master', 'puppet strings', 'music', 'rave in the redwoods', 'infinite warfare');
    ///     ('RITR_BelowTableFirstFloorRaveZoom', 'yadayada', 0, 'a search label', 'master', 'puppet strings', 'music', 'rave in the redwoods', 'infinite warfare')
    /// ```
    ///
    /// And the following `IMAGE_VARIANT` table:
    /// ```
    ///     ('RITR_BelowTableFirstFloor', 'RITR_BelowTableFirstFloorZoom', 'zoom', 'glass', NULL, NULL, NULL, NULL, 'puppet strings', 'music', 'rave in the redwoods', 'infinite warfare');
    ///     ('RITR_BelowTableFirstFloor', 'RITR_BelowTableFirstFloorRave', 'rave', 'fire', NULL, NULL, NULL, NULL, 'puppet strings', 'music', 'rave in the redwoods', 'infinite warfare');
    ///     ('RITR_BelowTableFirstFloorRave', 'RITR_BelowTableFirstFloorRaveZoom', 'zoom', 'glass', NULL, NULL, NULL, NULL, 'puppet strings', 'music', 'rave in the redwoods', 'infinite warfare');
    /// ```
    ///
    /// Assume you ask to `DELETE` row `(RITR_BelowTableFirstFloorRave)` from `IMAGE`. This would result in the automatic deletion of the row
    /// `('RITR_BelowTableFirstFloor', 'RITR_BelowTableFirstFloorRave')` from `IMAGE_VARIANT` but the remaining rows that have
    /// `RITR_BelowTableFirstFloorRave` as a `master` would persist, as well as their matching records in `IMAGE`
    func makeCascadeMasterDeleteFromImageTrigger(for dbConnection: OpaquePointer) throws {
        let imageVariant = DomainModel.imageVariant
        let image = DomainModel.visualMedia
        
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS cascade_master_delete_from_image
            AFTER DELETE ON \(image.tableName)
            BEGIN
        
                -- Remove all the \(imageVariant.slaveColumn.template) of the deleted gallery from \(image.tableName)

                DELETE FROM \(image.tableName)
                WHERE (\(image.nameColumn.template), \(image.foreignKeys.galleryColumn.template), \(image.foreignKeys.toolColumn.template), \(image.foreignKeys.tabColumn.template), \(image.foreignKeys.mapColumn.template), \(image.foreignKeys.gameColumn.template)) IN (
                    SELECT
                        V.\(imageVariant.slaveColumn.template) AS \(image.nameColumn.template),
                        I.\(image.foreignKeys.galleryColumn.template),
                        I.\(image.foreignKeys.toolColumn.template),
                        I.\(image.foreignKeys.tabColumn.template),
                        I.\(image.foreignKeys.mapColumn.template),
                        I.\(image.foreignKeys.gameColumn.template)
                    FROM \(image.tableName) AS I JOIN \(imageVariant.tableName) AS V ON
                        I.\(image.foreignKeys.galleryColumn.template) = V.\(imageVariant.foreignKeys.galleryColumn.template) AND
                        I.\(image.foreignKeys.toolColumn.template) = V.\(imageVariant.foreignKeys.toolColumn.template) AND
                        I.\(image.foreignKeys.tabColumn.template) = V.\(imageVariant.foreignKeys.tabColumn.template) AND
                        I.\(image.foreignKeys.mapColumn.template) = V.\(imageVariant.foreignKeys.mapColumn.template) AND
                        I.\(image.foreignKeys.gameColumn.template) = V.\(imageVariant.foreignKeys.gameColumn.template) AND
                        V.\(imageVariant.masterColumn.template) = OLD.\(image.nameColumn.template) AND
                        I.\(image.nameColumn.template) = OLD.\(image.nameColumn.template)
                );
        
                -- Remove the relationship between the deleted gallery and its \(imageVariant.masterColumn.template), if exists
        
                DELETE FROM \(imageVariant.tableName)
                WHERE \(imageVariant.slaveColumn.template) = OLD.\(image.nameColumn.template) AND
                        \(imageVariant.foreignKeys.galleryColumn.template) = OLD.\(image.foreignKeys.galleryColumn.template) AND
                        \(imageVariant.foreignKeys.toolColumn.template) = OLD.\(image.foreignKeys.toolColumn.template) AND
                        \(imageVariant.foreignKeys.tabColumn.template) = OLD.\(image.foreignKeys.tabColumn.template) AND
                        \(imageVariant.foreignKeys.mapColumn.template) = OLD.\(image.foreignKeys.mapColumn.template) AND
                        \(imageVariant.foreignKeys.gameColumn.template) = OLD.\(imageVariant.foreignKeys.gameColumn.template);
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
