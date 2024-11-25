import Foundation
import SQLite

public extension String {
    func join(_ expressions: [Expressible]) -> Expressible {
        var (template, bindings) = ([String](), [Binding?]())
        for expressible in expressions {
            let expression = expressible.expression
            template.append(expression.template)
            bindings.append(contentsOf: expression.bindings)
        }
        return SQLite.Expression<Void>(template.joined(separator: self), bindings)
    }
}
