import Foundation
import SQLite3
import SQLite

protocol DBTableCreator {
    func makeTable(for dbConnection: OpaquePointer) throws
    var table: SQLite.Table { get }
    var tableName: String { get }
}
