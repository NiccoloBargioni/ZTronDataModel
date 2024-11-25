import SQLite

public extension SQLite.ExpressionType {
    func alias(name:String) -> Expressible {
        return " ".join([self, Expression<Void>(literal: "AS \(name.withQuotes())")])
    }
}
