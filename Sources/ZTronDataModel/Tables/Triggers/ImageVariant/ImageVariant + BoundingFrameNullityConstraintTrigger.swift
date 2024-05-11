import Foundation

extension ImageVariant {
    func makeBoundingFrameNullityCheckTrigger(for dbConnection: OpaquePointer) throws {
        let imageVariant = DomainModel.imageVariant
        
        let triggerQuery = """
            CREATE TRIGGER IF NOT EXISTS image_variant_bounding_frame_nullity_validation
            BEFORE INSERT ON \(imageVariant.tableName)
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT (
                        (
                            NEW.\(imageVariant.boundingFrameOriginXColumn.template) IS NULL AND
                            NEW.\(imageVariant.boundingFrameOriginYColumn.template) IS NULL AND
                            NEW.\(imageVariant.boundingFrameWidthColumn.template) IS NULL AND
                            NEW.\(imageVariant.boundingFrameHeightColumn.template) IS NULL
                        ) OR (
                            NEW.\(imageVariant.boundingFrameOriginXColumn.template) IS NOT NULL AND
                            NEW.\(imageVariant.boundingFrameOriginYColumn.template) IS NOT NULL AND
                            NEW.\(imageVariant.boundingFrameWidthColumn.template) IS NOT NULL AND
                            NEW.\(imageVariant.boundingFrameHeightColumn.template) IS NOT NULL AND
                            
                            NEW.\(imageVariant.boundingFrameWidthColumn.template) BETWEEN 0 AND 1 AND
                            NEW.\(imageVariant.boundingFrameHeightColumn.template) BETWEEN 0 AND 1
                        )
                    )
                THEN
                    RAISE(ABORT, 'bounding frame attributes must be either all NULL or all NOT NULL when inserting on table \(imageVariant.tableName)')
                END;
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: triggerQuery)
    }
}
