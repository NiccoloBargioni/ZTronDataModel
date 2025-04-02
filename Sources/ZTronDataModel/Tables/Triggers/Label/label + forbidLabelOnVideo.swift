import Foundation

extension Label {
    func forbidLabelOnVideo(for dbConnection: OpaquePointer) throws {
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS forbid_label_on_video
            BEFORE INSERT ON \(DomainModel.outline.tableName)
            FOR EACH ROW
            WHEN (
                SELECT \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.typeColumn.template) 
                FROM \(DomainModel.visualMedia.tableName) JOIN \(DomainModel.label.tableName) ON
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.nameColumn.template) = \(DomainModel.label.tableName).\(DomainModel.label.foreignKeys.imageColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.galleryColumn.template) = \(DomainModel.label.tableName).\(DomainModel.label.foreignKeys.galleryColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.toolColumn.template) = \(DomainModel.label.tableName).\(DomainModel.label.foreignKeys.toolColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.tabColumn.template) = \(DomainModel.label.tableName).\(DomainModel.label.foreignKeys.tabColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.mapColumn.template) = \(DomainModel.label.tableName).\(DomainModel.label.foreignKeys.mapColumn.template) AND
                \(DomainModel.visualMedia.tableName).\(DomainModel.visualMedia.foreignKeys.gameColumn.template) = \(DomainModel.label.tableName).\(DomainModel.label.foreignKeys.gameColumn.template)
            ) <> 'image'
            BEGIN
                SELECT RAISE(ABORT, 'cannot attach a label to a video');
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
