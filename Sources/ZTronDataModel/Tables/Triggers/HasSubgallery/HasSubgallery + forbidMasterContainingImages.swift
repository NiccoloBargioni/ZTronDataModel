import Foundation

extension HasSubgallery {
    func makeForbidMasterContainingImagesTrigger(for dbConnection: OpaquePointer) throws {
        let subgallery = DomainModel.subgallery
        let visualMedia = DomainModel.visualMedia
        let gallery = DomainModel.gallery
        
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS forbid_master_containing_images
            BEFORE INSERT ON \(subgallery.tableName)
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM \(visualMedia.tableName) as I JOIN \(gallery.tableName) as G ON
                            I.\(visualMedia.foreignKeys.galleryColumn.template) = G.\(gallery.nameColumn.template) AND
                            I.\(visualMedia.foreignKeys.toolColumn.template) = G.\(gallery.foreignKeys.toolColumn.template) AND
                            I.\(visualMedia.foreignKeys.tabColumn.template) = G.\(gallery.foreignKeys.tabColumn.template) AND
                            I.\(visualMedia.foreignKeys.mapColumn.template) = G.\(gallery.foreignKeys.mapColumn.template) AND
                            I.\(visualMedia.foreignKeys.gameColumn.template) = G.\(gallery.foreignKeys.gameColumn.template)
                        WHERE
                            G.\(gallery.nameColumn.template) = NEW.\(subgallery.masterColumn.template)
                    )
                    THEN
                        RAISE(ABORT, 'Attempting to create a relationship between two galleries where the master has at least one associated image, on insert on table \(subgallery.tableName)')
                END;
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
