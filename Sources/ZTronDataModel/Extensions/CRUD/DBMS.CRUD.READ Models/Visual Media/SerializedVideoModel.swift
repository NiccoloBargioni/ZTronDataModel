import Foundation
import SQLite3
import SQLite


/// - `VISUAL_MEDIA(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
public final class SerializedVideoModel: SerializedVisualMediaModel {
    private let name: String
    private let description: String
    private let position: Int
    private let searchLabel: String?
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    private let `extension`: String
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let image = DBMS.visualMedia

        guard let `extension` = (namespaceColumns) ? fromRow[image.table[image.extensionColumn]] : fromRow[image.extensionColumn] else {
            fatalError("Unexpectedly found empty extension for video \((namespaceColumns) ? fromRow[image.table[image.nameColumn]] : fromRow[image.nameColumn])")
        }

                
        self.name = (namespaceColumns) ? fromRow[image.table[image.nameColumn]] : fromRow[image.nameColumn]
        self.description = (namespaceColumns) ? fromRow[image.table[image.descriptionColumn]] : fromRow[image.descriptionColumn]
        self.position = (namespaceColumns) ? fromRow[image.table[image.positionColumn]] : fromRow[image.positionColumn]
        self.searchLabel = (namespaceColumns) ? fromRow[image.table[image.searchLabelColumn]] : fromRow[image.searchLabelColumn]
        self.gallery = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.galleryColumn]] : fromRow[image.foreignKeys.galleryColumn]
        self.tool = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.toolColumn]] : fromRow[image.foreignKeys.toolColumn]
        self.tab = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.tabColumn]] : fromRow[image.foreignKeys.tabColumn]
        self.map = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.mapColumn]] : fromRow[image.foreignKeys.mapColumn]
        self.game = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.gameColumn]] : fromRow[image.foreignKeys.gameColumn]
        self.extension = `extension`
    }
    
    internal init(
        name: String,
        extension: String,
        description: String,
        position: Int,
        searchLabel: String?,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.name = name
        self.description = description
        self.position = position
        self.searchLabel = searchLabel
        self.gallery = gallery
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game
        self.extension = `extension`
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedVideoModel, rhs: SerializedVideoModel) -> Bool {
        return lhs.name == rhs.name && lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
        lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game && lhs.extension == rhs.extension
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
    
    public func getType() -> VisualMediaType {
        return .video
    }
    
    public func getExtension() -> String {
        return self.extension
    }
    
    public func toString() -> String {
        return """
        VISUAL_MEDIA(
            type: video,
            extension: \(self.extension),
            name: \(self.name),
            description: \(self.description),
            position: \(self.position),
            searchLabel: \(String(describing: self.searchLabel)),
            gallery: \(self.gallery),
            tool: \(self.tool),
            tab: \(self.tab),
            map: \(self.map),
            game: \(self.game)
        )
        """
    }
}
