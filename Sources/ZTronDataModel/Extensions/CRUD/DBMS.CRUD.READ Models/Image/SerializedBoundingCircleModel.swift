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
    
    internal init(_ fromRow: Row) {
        let boundingCircle = DBMS.boundingCircle
        
        self.colorHex = fromRow[boundingCircle.colorHexColumn]
        self._isActive = fromRow[boundingCircle.isActiveColumn]
        self.opacity = fromRow[boundingCircle.opacityColumn]
        self.idleDiameter = fromRow[boundingCircle.idleDiameterColumn]
        
        let cx = fromRow[boundingCircle.normalizedCenterXColumn]
        let cy = fromRow[boundingCircle.normalizedCenterYColumn]
        
        if cx == nil && cy != nil || cx != nil && cy == nil {
            fatalError("cx and cy must be either both nil or both not nil for image \(fromRow[boundingCircle.foreignKeys.imageColumn])")
        }
        
        if let cx = cx, let cy = cy {
            self.normalizedCenter = CGPoint(x: cx, y: cy)
        } else {
            self.normalizedCenter = nil
        }
        
        self.image = fromRow[boundingCircle.foreignKeys.imageColumn]
        self.gallery = fromRow[boundingCircle.foreignKeys.galleryColumn]
        self.tool = fromRow[boundingCircle.foreignKeys.toolColumn]
        self.tab = fromRow[boundingCircle.foreignKeys.tabColumn]
        self.map = fromRow[boundingCircle.foreignKeys.mapColumn]
        self.game = fromRow[boundingCircle.foreignKeys.gameColumn]
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
