import Foundation

extension Label {
    func forbidLabelOnVideo(for dbConnection: OpaquePointer) throws {
        let createTriggerQuery = """
            CREATE TRIGGER forbid_label_on_video
            BEFORE INSERT ON \(DomainModel.outline.tableName)
            FOR EACH ROW
            WHEN (
                SELECT \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.typeColumn.template) 
                FROM \(DomainModel.visualMedia.tableName) JOIN \(DomainModel.label.tableName) ON
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.nameColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.label.foreignKeys.imageColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.galleryColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.label.foreignKeys.galleryColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.toolColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.label.foreignKeys.toolColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.tabColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.label.foreignKeys.tabColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.mapColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.label.foreignKeys.mapColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.gameColumn.template) = \(DomainModel.boundingCircle.tableName).\(DomainModel.label.foreignKeys.gameColumn.template)
            ) <> 'image'
            BEGIN
                SELECT RAISE(ABORT, 'cannot attach a label to a video');
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
