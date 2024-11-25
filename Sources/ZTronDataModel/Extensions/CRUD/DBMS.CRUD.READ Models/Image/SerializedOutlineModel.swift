import Foundation
import SQLite
import SQLite3

/// - `OUTLINE(colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
public final class SerializedOutlineModel: ReadImageOptional {
    private let resourceName: String
    private let colorHex: String
    private let _isActive: Bool
    private let opacity: Double
    private let boundingBox: CGRect
    private let image: String
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    
    internal init(
        resourceName: String,
        colorHex: String,
        isActive: Bool,
        opacity: Double,
        boundingBoxOriginXColumn: Double,
        boundingBoxOriginYColumn: Double,
        boundingBoxWidthColumn: Double,
        boundingBoxHeightColumn: Double,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.resourceName = resourceName
        self.colorHex = colorHex
        self._isActive = isActive
        self.opacity = opacity
        
        self.boundingBox = CGRect(
            origin: CGPoint(
                x: boundingBoxOriginXColumn,
                y: boundingBoxOriginYColumn
            ),
            size: CGSize(
                width: boundingBoxWidthColumn,
                height: boundingBoxHeightColumn
            )
        )
        
        self.image = image
        self.gallery = gallery
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game

    }
    
    convenience internal init(_ fromRow: Row) {
        let outline = DBMS.outline

        self.init(
            resourceName: fromRow[outline.resourceNameColumn],
            colorHex: fromRow[outline.colorHexColumn],
            isActive: fromRow[outline.isActiveColumn],
            opacity: fromRow[outline.opacityColumn],
            boundingBoxOriginXColumn: fromRow[outline.boundingBoxOriginXColumn],
            boundingBoxOriginYColumn: fromRow[outline.boundingBoxOriginYColumn],
            boundingBoxWidthColumn: fromRow[outline.boundingBoxWidthColumn],
            boundingBoxHeightColumn: fromRow[outline.boundingBoxHeightColumn],
            image: fromRow[outline.foreignKeys.imageColumn],
            gallery: fromRow[outline.foreignKeys.galleryColumn],
            tool: fromRow[outline.foreignKeys.toolColumn],
            tab: fromRow[outline.foreignKeys.tabColumn],
            map: fromRow[outline.foreignKeys.mapColumn],
            game: fromRow[outline.foreignKeys.gameColumn]
        )
    }
    
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.image)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedOutlineModel, rhs: SerializedOutlineModel) -> Bool {
        return lhs.image == rhs.image && lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
            lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game
    }
    
    public func getResourceName() -> String {
        return self.resourceName
    }
    
    public func getColorHex() -> String {
        return self.colorHex
    }
    
    public func isActive() -> Bool {
        return self._isActive
    }
    
    public func getOpacity() -> Double {
        return self.opacity
    }
    
    public func getBoundingBox() -> CGRect {
        return self.boundingBox
    }
    
    public func getImage() -> String {
        return self.image
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
