import Foundation

extension Label {
    func makeMaxAABBNotNullConstraint(for dbConnection: OpaquePointer) throws {
        let labelModel = DomainModel.label

        let createTriggerQuery = """
            CREATE TRIGGER IF NOT EXISTS label_not_null_constraints
            BEFORE INSERT ON \(labelModel.tableName)
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT (
                        (
                            NEW.\(labelModel.maxAABBOriginXColumn.template) IS NULL AND
                            NEW.\(labelModel.maxAABBOriginYColumn.template) IS NULL AND
                            NEW.\(labelModel.maxAABBWidthColumn.template) IS NULL AND
                            NEW.\(labelModel.maxAABBHeightColumn.template) IS NULL
                        ) OR (
                            NEW.\(labelModel.maxAABBOriginXColumn.template) IS NOT NULL AND
                            NEW.\(labelModel.maxAABBOriginYColumn.template) IS NOT NULL AND
                            NEW.\(labelModel.maxAABBWidthColumn.template) IS NOT NULL AND
                            NEW.\(labelModel.maxAABBHeightColumn.template) IS NOT NULL AND
                            NEW.\(labelModel.maxAABBOriginXColumn.template) BETWEEN 0 AND 1 AND
                            NEW.\(labelModel.maxAABBOriginYColumn.template) BETWEEN 0 AND 1 AND
                            NEW.\(labelModel.maxAABBWidthColumn.template) BETWEEN 0 AND 1 AND
                            NEW.\(labelModel.maxAABBHeightColumn.template) BETWEEN 0 AND 1
                        )
                    )
                    THEN
                        RAISE(ABORT, '\(labelModel.maxAABBOriginXColumn.template),\(labelModel.maxAABBOriginYColumn.template), \(labelModel.maxAABBWidthColumn.template) and \(labelModel.maxAABBHeightColumn.template) must either be all NULL or all NOT NULL when inserting on table \(labelModel.tableName)')
                END;
            END;
        """
        
        try DBMS.performSQLStatement(for: dbConnection, query: createTriggerQuery)
    }
}
