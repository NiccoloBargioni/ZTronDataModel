import Foundation

extension VisualMedia {
    func forbidEmptyExtensionForVideo(for dbConnection: OpaquePointer) throws {        
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS forbid_empty_extension_for_video
            BEFORE INSERT ON \(DomainModel.visualMedia.tableName)
            FOR EACH ROW
                WHEN NEW.\(DomainModel.visualMedia.typeColumn.template) = 'video' AND NEW.\(DomainModel.visualMedia.extensionColumn.template) IS NULL
                OR NEW.\(DomainModel.visualMedia.typeColumn.template) = 'image' AND NEW.\(DomainModel.visualMedia.extensionColumn.template) IS NOT NULL
            BEGIN
                SELECT RAISE(ABORT, 'videos must have nonempty extension, image must not provide an extension.');
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
