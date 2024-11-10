import Foundation
import SQLite3
import SQLite

public final class SerializedSearchTokenModel: ReadGalleryOptional {
    private let title: String
    private let icon: String
    private let iconColorHex: String
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    
    internal init(_ fromRow: Row) {
        let searchToken = DBMS.gallerySearchToken
        
        self.title = fromRow[searchToken.titleColumn]
        self.icon = fromRow[searchToken.iconColumn]
        self.iconColorHex = fromRow[searchToken.iconColumn]
        
        
        self.gallery = fromRow[searchToken.foreignKeys.galleryColumn]
        self.tool = fromRow[searchToken.foreignKeys.toolColumn]
        self.tab = fromRow[searchToken.foreignKeys.tabColumn]
        self.map = fromRow[searchToken.foreignKeys.mapColumn]
        self.game = fromRow[searchToken.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedSearchTokenModel, rhs: SerializedSearchTokenModel) -> Bool {
        return lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
        lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game && lhs.title == rhs.title && lhs.icon == rhs.icon && lhs.iconColorHex == rhs.iconColorHex
    }

    public func getTitle() -> String {
        return self.title
    }
    
    public func getIcon() -> String {
        return self.icon
    }
    
    public func getIconColorHex() -> String {
        return self.iconColorHex
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
