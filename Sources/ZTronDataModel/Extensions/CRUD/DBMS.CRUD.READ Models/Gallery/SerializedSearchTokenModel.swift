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
    
    internal init(
        title: String,
        icon: String,
        iconColorHex: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.title = title
        self.icon = icon
        self.iconColorHex = iconColorHex
        self.gallery = gallery
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game
    }
    
    internal convenience init(_ fromRow: Row) {
        let searchToken = DBMS.gallerySearchToken
        
        self.init(
            title: fromRow[searchToken.titleColumn],
            icon: fromRow[searchToken.iconColumn],
            iconColorHex: fromRow[searchToken.iconColorHexColumn],
            gallery: fromRow[searchToken.foreignKeys.galleryColumn],
            tool: fromRow[searchToken.foreignKeys.toolColumn],
            tab: fromRow[searchToken.foreignKeys.tabColumn],
            map: fromRow[searchToken.foreignKeys.mapColumn],
            game: fromRow[searchToken.foreignKeys.gameColumn]
        )        
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
