import Foundation
import SQLite3
import SQLite

/// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
public final class SerializedGalleryModel: ReadGalleryOptional {
    private let name: String
    private let position: Int
    private let assetsImageName: String?
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    
    internal init(
        name: String,
        position: Int,
        assetsImageName: String?,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.name = name
        self.position = position
        self.assetsImageName = assetsImageName
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game
    }
    
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let gallery = DBMS.gallery
        
        self.name = namespaceColumns ? fromRow[gallery.table[gallery.nameColumn]] :  fromRow[gallery.nameColumn]
        self.position = namespaceColumns ? fromRow[gallery.table[gallery.positionColumn]] : fromRow[gallery.positionColumn]
        self.assetsImageName = namespaceColumns ? fromRow[gallery.table[gallery.assetsImageNameColumn]] : fromRow[gallery.assetsImageNameColumn]
        self.tool = namespaceColumns ? fromRow[gallery.table[gallery.foreignKeys.toolColumn]] : fromRow[gallery.foreignKeys.toolColumn]
        self.tab = namespaceColumns ? fromRow[gallery.table[gallery.foreignKeys.tabColumn]] : fromRow[gallery.foreignKeys.tabColumn]
        self.map = namespaceColumns ? fromRow[gallery.table[gallery.foreignKeys.mapColumn]] : fromRow[gallery.foreignKeys.mapColumn]
        self.game = namespaceColumns ? fromRow[gallery.table[gallery.foreignKeys.gameColumn]] : fromRow[gallery.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.tool)
    }
    
    public static func == (lhs: SerializedGalleryModel, rhs: SerializedGalleryModel) -> Bool {
        return lhs.name == rhs.name && lhs.tool == rhs.tool &&
        lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game && lhs.position == rhs.position && lhs.assetsImageName == rhs.assetsImageName
    }
    
    public func getName() -> String {
        return self.name
    }
        
    public func getPosition() -> Int {
        return self.position
    }
    
    public func getAssetsImageName() -> String? {
        return self.assetsImageName
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
