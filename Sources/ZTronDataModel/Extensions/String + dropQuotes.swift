import Foundation

extension String {
    func withQuotes() -> String {
        return "\"".appending(self).appending("\"")
    }
}
