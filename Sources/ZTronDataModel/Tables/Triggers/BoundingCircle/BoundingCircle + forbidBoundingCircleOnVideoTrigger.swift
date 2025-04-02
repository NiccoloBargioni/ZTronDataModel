import Foundation

extension BoundingCircle {
    func forbidBoundingCircleOnVideo(for dbConnection: OpaquePointer) throws {        
        let createTriggerQuery = """
            CREATE TRIGGER forbid_bounding_circle_on_video
            BEFORE INSERT ON \(DomainModel.boundingCircle.tableName)
            FOR EACH ROW
            WHEN (
                SELECT \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.typeColumn.template) 
                FROM \(DomainModel.visualMedia.tableName) JOIN \(DomainModel.boundingCircle.tableName) ON
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.nameColumn.template) = \(DomainModel.boundingCircle.foreignKeys.imageColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.galleryColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.boundingCircle.foreignKeys.galleryColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.toolColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.boundingCircle.foreignKeys.toolColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.tabColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.boundingCircle.foreignKeys.tabColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.mapColumn.template) = \(DomainModel.boundingCircle.foreignKeys.mapColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.gameColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.boundingCircle.foreignKeys.gameColumn.template)
            ) <> 'image'
            BEGIN
                SELECT RAISE(ABORT, 'cannot attach a bounding circle to a video');
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
