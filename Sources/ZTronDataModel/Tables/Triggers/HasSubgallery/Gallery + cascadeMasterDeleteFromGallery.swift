import Foundation

extension HasSubgallery {
    
    /// When a row from `GALLERY` is deleted, the matching gallery might or might not be a `slave`, a `master`, or both.
    ///
    /// -  if the deleted gallery was a `slave`, there exists a single `gallery` that could be its master, by design, and the relationship must be disposed.
    /// - if the deleted gallery was a `master`, it might have been a `master` for a whole subhierarchy, whose `slave`s need to be removed from `HAS-SUBGALLERY`
    ///     and from `GALLERY`.
    ///
    /// `HAS-SUBGALLERY` carries an explicit referential integrity constraint on its attributes (`slave`, `tool`, `tab`, `game`, `map`) referencing ``GALLERY``
    /// with an `ON DELETE CASCADE` clause.
    ///
    /// This entails that whenever a gallery that's a `slave` is deleted from `GALLERY`, all the rows where it appears as a `slave` (subgallery) get automatically removed.
    /// Though, this doesn't automatically fire the removal of all of its subhierarchy.
    ///
    /// To fire it, this trigger deletes from `GALLERY` all the entries where the deleted gallery appeared as a master
    ///
    /// - Example:
    /// Consider the following `GALLERY` table:
    ///
    /// ```
    ///     ('master', 'master', 'galleryPlaceholder', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals')
    ///     ('1,3,5-tera-nitra-phenol', '1,3,5-tera-nitra-phenol', 'galleryPlaceholder', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals');
    ///     ('phenol', 'phenol', 'galleryPlaceholder', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals');
    ///     ('phenosulphuric acid', 'phenosulphuric acid', 'galleryPlaceholder', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals')
    ///     ('1,3,5-tera-nitra-phenol-chemical', '1,3,5-tera-nitra-phenol', 'galleryPlaceholder', 'Infinite Warfare', 'Attack Of The Radioactive Thing', 'Easter Egg', 'chemicals');
    /// ```
    ///
    /// And the following `HAS_SUBGALLERY` table:
    ///
    /// ```
    ///     ('master', '1,3,5-tera-nitra-phenol', '0', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals');
    ///     ('1,3,5-tera-nitra-phenol', 'phenol', '0', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals');
    ///     ('1,3,5-tera-nitra-phenol', 'phenosulphuric acid', '1', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals');
    ///     ('1,3,5-tera-nitra-phenol', '1,3,5-tera-nitra-phenol-chemical', '2', 'infinite warfare', 'attack of the radioactive thing', 'easter egg', 'chemicals')
    /// ```
    ///
    /// Assume you ask to `DELETE` row `(1,3,5-tera-nitra-phenol)` from `GALLERY`. This would result in the automatic deletion of the row `('master', '1,3,5-tera-nitra-phenol')` from `HAS_SUBGALLERY`
    /// but the remaining rows that have `1,3,5-tera-nitra-phenol` as a `master` would persist, as well as their matching records in `GALLERY`
    func makeCascadeMasterDeleteFromGalleryTrigger(for dbConnection: OpaquePointer) throws {
        let subgallery = DomainModel.subgallery
        let gallery = DomainModel.gallery
        
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS cascade_master_delete_from_gallery
            AFTER DELETE ON \(gallery.tableName)
            BEGIN
        
                -- Remove all the \(subgallery.slaveColumn.template) of the deleted gallery from \(gallery.tableName)

                DELETE FROM \(gallery.tableName)
                WHERE (\(gallery.nameColumn.template), \(gallery.foreignKeys.toolColumn.template), \(gallery.foreignKeys.tabColumn.template), \(gallery.foreignKeys.mapColumn.template), \(gallery.foreignKeys.gameColumn.template)) IN (
                    SELECT
                        S.\(subgallery.slaveColumn.template) AS \(gallery.nameColumn.template),
                        G.\(gallery.foreignKeys.toolColumn.template),
                        G.\(gallery.foreignKeys.tabColumn.template),
                        G.\(gallery.foreignKeys.mapColumn.template),
                        G.\(gallery.foreignKeys.gameColumn.template)
                    FROM \(gallery.tableName) AS G JOIN \(subgallery.tableName) AS S ON
                        G.\(gallery.foreignKeys.toolColumn.template) = S.\(subgallery.foreignKeys.toolColumn.template) AND
                        G.\(gallery.foreignKeys.tabColumn.template) = S.\(subgallery.foreignKeys.tabColumn.template) AND
                        G.\(gallery.foreignKeys.mapColumn.template) = S.\(subgallery.foreignKeys.mapColumn.template) AND
                        G.\(gallery.foreignKeys.gameColumn.template) = S.\(subgallery.foreignKeys.gameColumn.template) AND
                        S.\(subgallery.masterColumn.template) = OLD.\(gallery.nameColumn.template) AND
                        G.\(gallery.nameColumn.template) = OLD.\(gallery.nameColumn.template)
                );
        
                -- Remove the relationship between the deleted gallery and its \(subgallery.masterColumn.template), if exists
        
                DELETE FROM \(subgallery.tableName)
                WHERE \(subgallery.slaveColumn.template) = OLD.\(gallery.nameColumn.template) AND
                        \(subgallery.foreignKeys.toolColumn.template) = OLD.\(gallery.foreignKeys.toolColumn.template) AND
                        \(subgallery.foreignKeys.tabColumn.template) = OLD.\(gallery.foreignKeys.tabColumn.template) AND
                        \(subgallery.foreignKeys.mapColumn.template) = OLD.\(gallery.foreignKeys.mapColumn.template) AND
                        \(subgallery.foreignKeys.gameColumn.template) = OLD.\(subgallery.foreignKeys.gameColumn.template);
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
