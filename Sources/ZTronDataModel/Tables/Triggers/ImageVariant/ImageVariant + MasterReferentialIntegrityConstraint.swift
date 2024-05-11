import Foundation

extension ImageVariant {
    func makeMasterReferentialIntegrityConstraintTrigger(for dbConnection: OpaquePointer) throws {
        let imageVariant = DomainModel.imageVariant
        let image = DomainModel.image
        
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS master_referential_integrity_image_variant
            BEFORE INSERT ON \(imageVariant.tableName)
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT EXISTS (
                        SELECT 1
                        FROM \(image.tableName)
                        WHERE
                            \(image.nameColumn.template) = NEW.\(imageVariant.masterColumn.template) AND
                            \(image.foreignKeys.galleryColumn.template) = NEW.\(imageVariant.foreignKeys.galleryColumn.template) AND
                            \(image.foreignKeys.toolColumn.template) = NEW.\(imageVariant.foreignKeys.toolColumn.template) AND
                            \(image.foreignKeys.tabColumn.template) = NEW.\(imageVariant.foreignKeys.tabColumn.template) AND
                            \(image.foreignKeys.mapColumn.template) = NEW.\(imageVariant.foreignKeys.mapColumn.template) AND
                            \(image.foreignKeys.gameColumn.template) = NEW.\(imageVariant.foreignKeys.gameColumn.template)
                    )
                    THEN
                        RAISE(ABORT, 'Attempted to add a new image variant before inserting master into \(image.tableName)')
                END;
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
