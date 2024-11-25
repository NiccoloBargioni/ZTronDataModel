import Foundation
import SQLite3
import SQLite

public final class SerializedBoundingCircleModel: ReadImageOptional {
    private let colorHex: String
    private let _isActive: Bool
    private let opacity: Double
    private let idleDiameter: Double?
    private let normalizedCenter: CGPoint?
    private let image: String
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    
    convenience internal init(_ fromRow: Row) {
        let boundingCircle = DBMS.boundingCircle
        
        self.init(
            colorHex: fromRow[boundingCircle.colorHexColumn],
            isActive: fromRow[boundingCircle.isActiveColumn],
            opacity: fromRow[boundingCircle.opacityColumn],
            idleDiameter: fromRow[boundingCircle.idleDiameterColumn],
            normalizedCenterX: fromRow[boundingCircle.normalizedCenterXColumn],
            normalizedCenterY: fromRow[boundingCircle.normalizedCenterYColumn],
            image: fromRow[boundingCircle.foreignKeys.imageColumn],
            gallery: fromRow[boundingCircle.foreignKeys.galleryColumn],
            tool: fromRow[boundingCircle.foreignKeys.toolColumn],
            tab: fromRow[boundingCircle.foreignKeys.tabColumn],
            map: fromRow[boundingCircle.foreignKeys.mapColumn],
            game: fromRow[boundingCircle.foreignKeys.gameColumn]
        )
    }
    
    internal init(
        colorHex: String,
        isActive: Bool,
        opacity: Double,
        idleDiameter: Double?,
        normalizedCenterX: Double?,
        normalizedCenterY: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.colorHex = colorHex
        self._isActive = isActive
        self.opacity = opacity
        self.idleDiameter = idleDiameter
        
        let cx = normalizedCenterX
        let cy = normalizedCenterY
        
        if cx == nil && cy != nil || cx != nil && cy == nil {
            fatalError("cx and cy must be either both nil or both not nil for image \(image)")
        }
        
        if let cx = cx, let cy = cy {
            self.normalizedCenter = CGPoint(x: cx, y: cy)
        } else {
            self.normalizedCenter = nil
        }
        
        self.image = image
        self.gallery = gallery
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.image)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedBoundingCircleModel, rhs: SerializedBoundingCircleModel) -> Bool {
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
    
    public func getIdleDiameter() -> Double? {
        return self.idleDiameter
    }
    
    public func getNormalizedCenter() -> CGPoint? {
        return self.normalizedCenter
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
