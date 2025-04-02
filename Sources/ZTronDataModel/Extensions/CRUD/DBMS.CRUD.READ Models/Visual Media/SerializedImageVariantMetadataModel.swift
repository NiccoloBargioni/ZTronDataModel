import Foundation
import SQLite
import SQLite3

/// - `IMAGE_VARIANT(master, slave, variant, bottomBarIcon, boundingFrameOriginX, boundingFrameOriginY, boundingFrameWidth, boundingFrameHeight, gallery, tool, tab, map, game)`
public final class SerializedImageVariantMetadataModel: ReadImageOptional {
    private let master: String
    private let slave: String
    private let variant: String
    private let bottomBarIcon: String
    private let goBackBottomBarIcon: String?
    private let boundingFrame: CGRect?
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    
    internal init(
        master: String,
        slave: String,
        variant: String,
        bottomBarIcon: String,
        goBackBottomBarIcon: String?,
        boundingFrameOriginX: Double?,
        boundingFrameOriginY: Double?,
        boundingFrameWidth: Double?,
        boundingFrameHeight: Double?,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.master = master
        self.slave = slave
        self.variant = variant
        self.bottomBarIcon = bottomBarIcon
        self.goBackBottomBarIcon = goBackBottomBarIcon
        
        let x = boundingFrameOriginX
        let y = boundingFrameOriginY
        let w = boundingFrameWidth
        let h = boundingFrameHeight

        if !((x == nil && y == nil && w == nil && h == nil) ||
             (x != nil && y != nil && w != nil && h != nil)) {
            fatalError("x,y,w,h must either be all nil or all not nil for slave \(slave)")
        }
        
        if let x = x, let y = y, let w = w, let h = h {
            self.boundingFrame = CGRect(
                origin: .init(x: x, y: y),
                size: .init(width: w, height: h)
            )
        } else {
            self.boundingFrame = nil
        }
        
        self.gallery = gallery
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game
    }
    
    convenience internal init(_ fromRow: Row) {
        let variant = DBMS.imageVariant
        
        self.init(
            master: fromRow[variant.masterColumn],
            slave: fromRow[variant.slaveColumn],
            variant: fromRow[variant.variantColumn],
            bottomBarIcon: fromRow[variant.bottomBarIconColumn],
            goBackBottomBarIcon: fromRow[variant.goBackBottomBarIconColumn],
            boundingFrameOriginX: fromRow[variant.boundingFrameOriginXColumn],
            boundingFrameOriginY: fromRow[variant.boundingFrameOriginYColumn],
            boundingFrameWidth: fromRow[variant.boundingFrameWidthColumn],
            boundingFrameHeight: fromRow[variant.boundingFrameHeightColumn],
            gallery: fromRow[variant.foreignKeys.galleryColumn],
            tool: fromRow[variant.foreignKeys.toolColumn],
            tab: fromRow[variant.foreignKeys.tabColumn],
            map: fromRow[variant.foreignKeys.mapColumn],
            game: fromRow[variant.foreignKeys.gameColumn]
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.master)
        hasher.combine(self.slave)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedImageVariantMetadataModel, rhs: SerializedImageVariantMetadataModel) -> Bool {
        return lhs.master == rhs.master && lhs.slave == rhs.slave && lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
            lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game
    }

    public func getMaster() -> String {
        return self.master
    }
    
    public func getSlave() -> String {
        return self.slave
    }
    
    public func getVariant() -> String {
        return self.variant
    }
    
    public func getBottomBarIcon() -> String {
        return self.bottomBarIcon
    }
    
    public func getGoBackBottomBarIcon() -> String? {
        return self.goBackBottomBarIcon
    }
    
    public func getBoundingFrame() -> CGRect? {
        return self.boundingFrame
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
