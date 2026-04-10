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

public extension SerializedVisualMediaModel {
    func erasedToAnySerializedVisualMediaModel() -> AnySerializedVisualMediaModel {
        return AnySerializedVisualMediaModel(self)
    }
}


public protocol SerializedVisualMediaModelWritableDraft {
    associatedtype M: SerializedVisualMediaModel
    
    @discardableResult func withName(_: String) -> Self
    @discardableResult func withDescription(_: String) -> Self
    @discardableResult func withPosition(_: Int) -> Self
    @discardableResult func withSearchLabel(_: String?) -> Self
    func getImmutableCopy() -> M
    
    func getName() -> String
    func getDescription() -> String
    func getPosition() -> Int
    func getSearchLabel() -> String?

    func getGallery() -> String
    func getTool() -> String
    func getTab() -> String
    func getMap() -> String
    func getGame() -> String
    
    func getPreviousName() -> String
    func getPreviousDescription() -> String
    func getPreviousPosition() -> Int
    func getPreviousSearchLabel() -> String?
}

internal protocol SerializedVisualMediaModelWritableDraftUpdateBearer {    
    func didNameUpdate() -> Bool
    func didDescriptionUpdate() -> Bool
    func didPositionUpdate() -> Bool
    func didSearchLabelUpdate() -> Bool
}
