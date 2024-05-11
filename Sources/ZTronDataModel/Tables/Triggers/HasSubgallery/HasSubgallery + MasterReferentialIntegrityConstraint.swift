import Foundation

extension HasSubgallery {
    internal func makeMasterReferentialIntegrityConstraintTrigger(for dbConnection: OpaquePointer) throws {
        let subgallery = DomainModel.subgallery
        let gallery = DomainModel.gallery
        
        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS master_referential_integrity_subgallery
            BEFORE INSERT ON \(subgallery.tableName)
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT EXISTS (
                        SELECT 1
                        FROM \(gallery.tableName)
                        WHERE
                            \(gallery.nameColumn.template) = NEW.\(subgallery.masterColumn.template) AND
                            \(gallery.foreignKeys.toolColumn.template) = NEW.\(subgallery.foreignKeys.toolColumn.template) AND
                            \(gallery.foreignKeys.tabColumn.template) = NEW.\(subgallery.foreignKeys.tabColumn.template) AND
                            \(gallery.foreignKeys.mapColumn.template) = NEW.\(subgallery.foreignKeys.mapColumn.template) AND
                            \(gallery.foreignKeys.gameColumn.template) = NEW.\(subgallery.foreignKeys.gameColumn.template)
                    )
                    THEN
                        RAISE(ABORT, 'Attempted to add a new Subgallery before inserting master into Gallery')
                END;
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
