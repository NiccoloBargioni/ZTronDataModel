import Foundation

extension Image {
    func makeForbidAttachingImageToMasterTrigger(for dbConnection: OpaquePointer) throws {
        let subgallery = DomainModel.subgallery
        let image = DomainModel.image
        
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS forbid_attaching_image_to_master
            BEFORE INSERT ON \(image.tableName)
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM \(subgallery.tableName) AS S
                        WHERE
                            S.\(subgallery.masterColumn.template) = NEW.\(image.foreignKeys.galleryColumn.template)
                    )
                    THEN
                        RAISE(ABORT, 'Attempting to attach an image to a master gallery, on insert on table \(image.tableName)')
                END;
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
