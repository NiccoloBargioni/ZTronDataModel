import Foundation
import SQLite3
import SQLite


/// - `IMAGE(name, description, position, searchLabel, gallery, tool, tab, map, game)`
public class SerializedImageModel: ReadImageOptional {
    private let name: String
    private let description: String
    private let position: Int
    private let searchLabel: String?
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    
    internal init(_ fromRow: Row) {
        let image = DBMS.image
        
        self.name = fromRow[image.nameColumn]
        self.description = fromRow[image.descriptionColumn]
        self.position = fromRow[image.positionColumn]
        self.searchLabel = fromRow[image.searchLabelColumn]
        self.gallery = fromRow[image.foreignKeys.galleryColumn]
        self.tool = fromRow[image.foreignKeys.toolColumn]
        self.tab = fromRow[image.foreignKeys.tabColumn]
        self.map = fromRow[image.foreignKeys.mapColumn]
        self.game = fromRow[image.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedImageModel, rhs: SerializedImageModel) -> Bool {
        return lhs.name == rhs.name && lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
            lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getDescription() -> String {
        return self.description
    }
    
    public func getPosition() -> Int {
        return self.position
    }
    
    public func getSearchLabel() -> String? {
        return self.searchLabel
    }
    
    public func getGallery() -> String {
        return self.gallery
    }
    
    public func getTool() -> String {
        return self.tool
    }
    
    public func getTab() -> String {
        return self.tab
    }
    
    public func getMap() -> String {
        return self.map
    }
    
    public func getGame() -> String {
        return self.game
    }
}
