import Foundation

public protocol SerializedVisualMediaModel: ReadImageOptional {
    associatedtype WD: SerializedVisualMediaModelWritableDraft
    func getName() -> String
    func getDescription() -> String
    func getPosition() -> Int
    func getSearchLabel() -> String?
    func getGallery() -> String
    func getTool() -> String
    func getTab() -> String
    func getMap() -> String
    func getGame() -> String
    func getType() -> VisualMediaType
    func toString() -> String
    
    func getMutableCopy() -> WD
}


public protocol SerializedVisualMediaModelWritableDraft {
    associatedtype M: SerializedVisualMediaModel
    
    func withName(_: String) -> Self
    func withDescription(_: String) -> Self
    func withPosition(_: Int) -> Self
    func withSearchLabel(_: String?) -> Self
    func getImmutableCopy() -> M
}
