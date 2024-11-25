import Foundation

internal extension String {
    func droppingQuotes(leading: Bool = true, trailing: Bool = true) -> String {
        var result = self
        
        if leading && self.first == "\"" {
            result = String(result.dropFirst())
        }
        
        if trailing && self.last == "\"" {
            result = String(result.dropLast())
        }
        
        return result
    }
}
