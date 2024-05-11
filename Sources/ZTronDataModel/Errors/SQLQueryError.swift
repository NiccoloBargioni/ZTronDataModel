import Foundation

public enum SQLQueryError: Error {
    case documentsPathNotFoundException(reason: String)
    case ioException(reason: String)
    case triggerException(reason: String)
    case tableCreationError(reason: String)
    case creationStatementPreparationError(reason: String)
    case unsatisfiedConvention(reason: String)
    case genericError(reason: String)
}
