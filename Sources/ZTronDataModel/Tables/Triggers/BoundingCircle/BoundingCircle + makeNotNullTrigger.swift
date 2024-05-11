import Foundation

extension BoundingCircle {
    func makeNotNullTrigger(for dbConnection: OpaquePointer) throws {
        let boundingCircleModel = DomainModel.boundingCircle

        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS bounding_circle_not_null_constraint
            BEFORE INSERT ON \(boundingCircleModel.tableName)
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT (
                        (
                            NEW.\(boundingCircleModel.normalizedCenterXColumn.template) IS NULL AND
                            NEW.\(boundingCircleModel.normalizedCenterYColumn.template) IS NULL
                        ) OR (
                            NEW.\(boundingCircleModel.normalizedCenterXColumn.template) IS NOT NULL AND
                            NEW.\(boundingCircleModel.normalizedCenterYColumn.template) IS NOT NULL AND
                            NEW.\(boundingCircleModel.normalizedCenterXColumn.template) BETWEEN 0 AND 1 AND
                            NEW.\(boundingCircleModel.normalizedCenterYColumn.template) BETWEEN 0 AND 1
                        )
                    )
                    THEN
                        RAISE(ABORT, '\(boundingCircleModel.normalizedCenterXColumn.template) and \(boundingCircleModel.normalizedCenterYColumn.template) must either be all NULL or all NOT NULL when inserting on table \(boundingCircleModel.tableName)')
                END;
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
