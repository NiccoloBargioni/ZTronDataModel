import Foundation
import SQLite
import SQLite3

/// - `OUTLINE(colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
public class SerializedOutlineModel: ReadImageOptional {
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
    
    internal init(_ fromRow: Row) {
        let outline = DBMS.outline
        self.colorHex = fromRow[outline.colorHexColumn]
        self._isActive = fromRow[outline.isActiveColumn]
        self.opacity = fromRow[outline.opacityColumn]
        
        self.boundingBox = CGRect(
            origin: CGPoint(
                x: fromRow[outline.boundingBoxOriginXColumn],
                y: fromRow[outline.boundingBoxOriginYColumn]
            ),
            size: CGSize(
                width: fromRow[outline.boundingBoxWidthColumn],
                height: fromRow[outline.boundingBoxOriginYColumn]
            )
        )
        
        self.image = fromRow[outline.foreignKeys.imageColumn]
        self.gallery = fromRow[outline.foreignKeys.galleryColumn]
        self.tool = fromRow[outline.foreignKeys.toolColumn]
        self.tab = fromRow[outline.foreignKeys.tabColumn]
        self.map = fromRow[outline.foreignKeys.mapColumn]
        self.game = fromRow[outline.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.image)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedOutlineModel, rhs: SerializedOutlineModel) -> Bool {
        return lhs.image == rhs.image && lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
            lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game
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
