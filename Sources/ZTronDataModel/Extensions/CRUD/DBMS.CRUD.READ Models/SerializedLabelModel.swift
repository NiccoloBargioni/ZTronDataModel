import Foundation
import SQLite
import SQLite3

public class SerializedLabelModel: ReadImageOptional {
    private let label: String
    private let _isActive: Bool
    private let icon: String?
    private let assetsImageName: String?
    private let textColorHex: String
    private let backgroundColorHex: String
    private let opacity: Double
    private let maxAABB: CGRect?
    private let image: String
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String

    internal init(_ fromRow: Row) {
        let labelModel = DBMS.label
        
        self.label = fromRow[labelModel.labelColumn]
        self._isActive = fromRow[labelModel.isActiveColumn]
        self.icon = fromRow[labelModel.iconColumn]
        self.assetsImageName = fromRow[labelModel.assetsImageNameColumn]
        self.textColorHex = fromRow[labelModel.textColorHexColumn]
        self.backgroundColorHex = fromRow[labelModel.backgroundColorHexColumn]
        self.opacity = fromRow[labelModel.opacityColumn]
        
        let x = fromRow[labelModel.maxAABBOriginXColumn]
        let y = fromRow[labelModel.maxAABBOriginYColumn]
        let w = fromRow[labelModel.maxAABBWidthColumn]
        let h = fromRow[labelModel.maxAABBHeightColumn]

        if !((x == nil && y == nil && w == nil && h == nil) ||
             (x != nil && y != nil && w != nil && h != nil)) {
            fatalError("x,y,w,h must either be all nil or all not nil for image \(fromRow[labelModel.foreignKeys.imageColumn])")
        }
        
        if let x = x, let y = y, let w = w, let h = h {
            self.maxAABB = CGRect(
                origin: CGPoint(x: x, y: y),
                size: CGSize(width: w, height: h)
            )
        } else {
            self.maxAABB = nil
        }
        
        self.image = fromRow[labelModel.foreignKeys.imageColumn]
        self.gallery = fromRow[labelModel.foreignKeys.galleryColumn]
        self.tool = fromRow[labelModel.foreignKeys.toolColumn]
        self.tab = fromRow[labelModel.foreignKeys.tabColumn]
        self.map = fromRow[labelModel.foreignKeys.mapColumn]
        self.game = fromRow[labelModel.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.image)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedLabelModel, rhs: SerializedLabelModel) -> Bool {
        return lhs.image == rhs.image && lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
            lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game
    }
    
    public func getLabel() -> String {
        return self.label
    }
    
    public func isActive() -> Bool {
        return self._isActive
    }
    
    public func getIcon() -> String? {
        return self.icon
    }
    
    public func getAssetsImageName() -> String? {
        return self.assetsImageName
    }
    
    public func getTextColorHex() -> String {
        return self.textColorHex
    }
    
    public func getBackgroundColorHex() -> String {
        return self.backgroundColorHex
    }
    
    public func getOpacity() -> Double {
        return self.opacity
    }
    
    public func getMaxAABB() -> CGRect? {
        return self.maxAABB
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

