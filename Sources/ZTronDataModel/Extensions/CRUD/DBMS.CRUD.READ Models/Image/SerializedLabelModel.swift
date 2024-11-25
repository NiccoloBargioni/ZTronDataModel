import Foundation
import SQLite
import SQLite3

public final class SerializedLabelModel: ReadImageOptional {
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

    internal init(
        label: String,
        isActive: Bool,
        icon: String?,
        assetsImageName: String?,
        textColorHex: String,
        backgroundColorHex: String,
        opacity: Double,
        maxAABBOriginX: Double?,
        maxAABBOriginY: Double?,
        maxAABBWidth: Double?,
        maxAABBHeight: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.label = label
        self._isActive = isActive
        self.icon = icon
        self.assetsImageName = assetsImageName
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
        self.opacity = opacity
        
        let x = maxAABBOriginX
        let y = maxAABBOriginY
        let w = maxAABBWidth
        let h = maxAABBHeight

        if !((x == nil && y == nil && w == nil && h == nil) ||
             (x != nil && y != nil && w != nil && h != nil)) {
            fatalError("x,y,w,h must either be all nil or all not nil for image \(image)")
        }
        
        if let x = x, let y = y, let w = w, let h = h {
            self.maxAABB = CGRect(
                origin: CGPoint(x: x, y: y),
                size: CGSize(width: w, height: h)
            )
        } else {
            self.maxAABB = nil
        }
        
        self.image = image
        self.gallery = gallery
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game
    }
    
    convenience internal init(_ fromRow: Row) {
        let labelModel = DBMS.label
        
        self.init(
            label: fromRow[labelModel.labelColumn],
            isActive: fromRow[labelModel.isActiveColumn],
            icon: fromRow[labelModel.iconColumn],
            assetsImageName: fromRow[labelModel.assetsImageNameColumn],
            textColorHex: fromRow[labelModel.textColorHexColumn],
            backgroundColorHex: fromRow[labelModel.backgroundColorHexColumn],
            opacity: fromRow[labelModel.opacityColumn],
            maxAABBOriginX: fromRow[labelModel.maxAABBOriginXColumn],
            maxAABBOriginY: fromRow[labelModel.maxAABBOriginYColumn],
            maxAABBWidth: fromRow[labelModel.maxAABBWidthColumn],
            maxAABBHeight: fromRow[labelModel.maxAABBHeightColumn],
            image: fromRow[labelModel.foreignKeys.imageColumn],
            gallery: fromRow[labelModel.foreignKeys.galleryColumn],
            tool: fromRow[labelModel.foreignKeys.toolColumn],
            tab: fromRow[labelModel.foreignKeys.tabColumn],
            map: fromRow[labelModel.foreignKeys.mapColumn],
            game: fromRow[labelModel.foreignKeys.gameColumn]
        )
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

