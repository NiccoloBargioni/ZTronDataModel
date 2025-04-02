import Foundation

extension Outline {
    func forbidOutlineOnVideo(for dbConnection: OpaquePointer) throws {
        let createTriggerQuery = """
            CREATE TRIGGER forbid_outline_on_video
            BEFORE INSERT ON \(DomainModel.outline.tableName)
            FOR EACH ROW
            WHEN (
                SELECT \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.typeColumn.template) 
                FROM \(DomainModel.visualMedia.tableName) JOIN \(DomainModel.outline.tableName) ON
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.nameColumn.template) = \(DomainModel.outline.tableName).\(DomainModel.outline.foreignKeys.imageColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.galleryColumn.template) = \(DomainModel.outline.tableName).\(DomainModel.outline.foreignKeys.galleryColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.toolColumn.template) = \(DomainModel.outline.tableName).\(DomainModel.outline.foreignKeys.toolColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.tabColumn.template) = \(DomainModel.outline.tableName).\(DomainModel.outline.foreignKeys.tabColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.mapColumn.template) = \(DomainModel.outline.tableName).\(DomainModel.outline.foreignKeys.mapColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.gameColumn.template) = \(DomainModel.outline.tableName).\(DomainModel.outline.foreignKeys.gameColumn.template)
            ) <> 'image'
            BEGIN
                SELECT RAISE(ABORT, 'cannot attach an outline to a video');
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
