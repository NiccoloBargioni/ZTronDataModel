import Foundation

public protocol SerializedVisualMediaModel: ReadImageOptional {
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
}
