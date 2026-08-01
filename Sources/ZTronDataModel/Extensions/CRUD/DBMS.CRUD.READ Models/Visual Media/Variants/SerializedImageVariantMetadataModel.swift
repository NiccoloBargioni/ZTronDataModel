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
    
    public final func getMutableCopy() -> SerializedImageVariantMetadataModel.WritableDraft {
        return .init(self)
    }
    
    public final class WritableDraft {
        private var bottomBarIcon: String
        private var goBackBottomBarIcon: String?
        private var boundingFrameOriginX: Double?
        private var boundingFrameOriginY: Double?
        private var boundingFrameWidth: Double?
        private var boundingFrameHeight: Double?
        weak private var owner: SerializedImageVariantMetadataModel?
        
        private var didBottomBarIconChange: Bool = false
        private var didGoBackBottomBarIconChange: Bool = false
        private var didBoundingFrameOriginXChange: Bool = false
        private var didBoundingFrameOriginYChange: Bool = false
        private var didBoundingFrameWidthChange: Bool = false
        private var didBoundingFrameHeightChange: Bool = false
        
        fileprivate init(_ owner: SerializedImageVariantMetadataModel) {
            self.bottomBarIcon = owner.bottomBarIcon
            self.goBackBottomBarIcon = owner.goBackBottomBarIcon
            self.boundingFrameOriginX = owner.boundingFrame?.origin.x
            self.boundingFrameOriginY = owner.boundingFrame?.origin.y
            self.boundingFrameWidth = owner.boundingFrame?.size.width
            self.boundingFrameHeight = owner.boundingFrame?.size.height
            self.owner = owner
        }

        @discardableResult public final func withBottomBarIcon(_ newBottomBarIcon: String) -> Self {
            self.bottomBarIcon = newBottomBarIcon.lowercased()
            self.didBottomBarIconChange = true
            return self
        }
        
        internal final func didBottomBarIconUpdate() -> Bool {
            return self.didBottomBarIconChange
        }
        
        public final func getPreviousBottomBarIcon() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `bottomBarIcon`.")
            }
            return owner.bottomBarIcon
        }
        
        @discardableResult public final func withGoBackBottomBarIcon(_ newGoBackBottomBarIcon: String?) -> Self {
            self.goBackBottomBarIcon = newGoBackBottomBarIcon
            self.didGoBackBottomBarIconChange = true
            return self
        }
        
        internal final func didGoBackBottomBarIconUpdate() -> Bool {
            return self.didGoBackBottomBarIconChange
        }
        
        public final func getPreviousGoBackBottomBarIcon() -> String? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `goBackBottomBaricon`.")
            }
            return owner.goBackBottomBarIcon
        }

        @discardableResult public final func withOriginX(_ newOriginX: Double) -> Self {
            assert(newOriginX >= 0 && newOriginX <= 1)
            self.boundingFrameOriginX = newOriginX
            self.didBoundingFrameOriginXChange = true
            return self
        }
        
        internal final func didOriginXUpdate() -> Bool {
            return self.didBoundingFrameOriginXChange
        }
        
        public final func getPreviousOriginX() -> Double? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `origin.x`.")
            }
            return owner.boundingFrame?.origin.x
        }

        
        @discardableResult public final func withOriginY(_ newOriginY: Double) -> Self {
            assert(newOriginY >= 0 && newOriginY <= 1)
            self.boundingFrameOriginY = newOriginY
            self.didBoundingFrameOriginYChange = true
            return self
        }
        
        internal final func didOriginYUpdate() -> Bool {
            return self.didBoundingFrameOriginYChange
        }

        
        public final func getPreviousOriginY() -> Double? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `origin.y`.")
            }
            return owner.boundingFrame?.origin.y
        }
        
        @discardableResult public final func withOrigin(_ origin: CGPoint?) -> Self {
            assert(origin?.x ?? 0 >= 0 && origin?.x ?? 0 <= 1)
            assert(origin?.y ?? 0 >= 0 && origin?.y ?? 0 <= 1)
            
            self.boundingFrameOriginX = origin?.x
            self.boundingFrameOriginY = origin?.y
            
            self.didBoundingFrameOriginXChange = true
            self.didBoundingFrameOriginYChange = true
            
            return self
        }
        
        public final func getPreviousOrigin() -> CGPoint? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `origin`.")
            }
            return owner.boundingFrame?.origin

        }
        
        internal final func didOriginUpdate() -> Bool {
            return self.didBoundingFrameOriginXChange || self.didBoundingFrameOriginYChange
        }

        @discardableResult public final func withWidth(_ newWidth: Double) -> Self {
            assert(newWidth >= 0 && newWidth <= 1)
            self.boundingFrameWidth = newWidth
            self.didBoundingFrameWidthChange = true
            return self
        }
        
        internal final func didWidthUpdate() -> Bool {
            return self.didBoundingFrameWidthChange
        }
        
        public final func getPreviousWidth() -> Double? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `size.width`.")
            }
            return owner.boundingFrame?.size.width
        }
        
        @discardableResult public final func withHeight(_ newHeight: Double) -> Self {
            assert(newHeight >= 0 && newHeight <= 1)
            self.boundingFrameHeight = newHeight
            self.didBoundingFrameHeightChange = true
            return self
        }
        
        
        internal final func didHeightUpdate() -> Bool {
            return self.didBoundingFrameHeightChange
        }
        
        public final func getPreviousHeight() -> Double? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `size.height`.")
            }
            return owner.boundingFrame?.size.height
        }
        
        @discardableResult public final func withSize(_ size: CGSize?) -> Self {
            assert(size?.width ?? 0 >= 0 && size?.width ?? 0 <= 1)
            assert(size?.height ?? 0 >= 0 && size?.height ?? 0 <= 1)
            
            self.boundingFrameWidth = size?.width
            self.boundingFrameHeight = size?.height
            
            self.didBoundingFrameWidthChange = true
            self.didBoundingFrameHeightChange = true
            
            return self
        }
        
        internal final func didSizeUpdate() -> Bool {
            return self.didBoundingFrameWidthChange || self.didBoundingFrameHeightChange
        }
        
        public final func getPreviousSize() -> CGSize? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `size`.")
            }
            return owner.boundingFrame?.size
        }

        
        public final func getBottomBarIcon() -> String {
            return self.bottomBarIcon
        }
        
        public final func getGoBackBottomBarIcon() -> String? {
            return self.goBackBottomBarIcon
        }
        
        public final func getOrigin() -> CGPoint? {
            guard let boundingFrameOriginX = self.boundingFrameOriginX else { return nil }
            guard let boundingFrameOriginY = self.boundingFrameOriginY else { return nil }
            
            return CGPoint(
                x: boundingFrameOriginX,
                y: boundingFrameOriginY
            )
        }
        
        public final func getOriginX() -> Double? {
            return self.boundingFrameOriginX
        }
        
        public final func getOriginY() -> Double? {
            return self.boundingFrameOriginY
        }
        
        public final func getSize() -> CGSize? {
            guard let boundingFrameWidth = self.boundingFrameWidth else { return nil }
            guard let boundingFrameHeight = self.boundingFrameHeight else { return nil }
            
            return CGSize(
                width: boundingFrameWidth,
                height: boundingFrameHeight
            )
        }
        
        public final func getWidth() -> Double? {
            return self.boundingFrameWidth
        }
        
        public final func getHeight() -> Double? {
            return self.boundingFrameHeight
        }
        
        public final func getSlave() -> String {
            guard let owner = self.owner else {
                fatalError("Failed to retain reference to owner before committing the draft.")
            }
            
            return owner.slave
        }
        
        public final func getMaster() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `master`.")
            }
            return owner.master
        }
                
        public final func getGallery() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `gallery`.")
            }
            return owner.gallery
        }
        
        public final func getTool() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `tool`.")
            }
            return owner.tool
        }
        
        public final func getTab() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `tab`.")
            }
            return owner.tab
        }
        
        public final func getMap() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `map`.")
            }
            return owner.map
        }
        
        public final func getGame() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `game`.")
            }
            return owner.game
        }
        
        internal final func getImmutableCopy() -> SerializedImageVariantMetadataModel {
            guard let owner = self.owner else {
                fatalError("Failed to retain reference to owner before committing the draft.")
            }
            
            assert((self.boundingFrameOriginX == nil && self.boundingFrameOriginY == nil && self.boundingFrameWidth == nil && self.boundingFrameHeight == nil) || (self.boundingFrameOriginX != nil && self.boundingFrameOriginY != nil && self.boundingFrameWidth != nil && self.boundingFrameHeight != nil))
            
            return .init(
                master: owner.master,
                slave: owner.slave,
                variant: owner.variant,
                bottomBarIcon: self.bottomBarIcon,
                goBackBottomBarIcon: self.goBackBottomBarIcon,
                boundingFrameOriginX: self.boundingFrameOriginX,
                boundingFrameOriginY: self.boundingFrameOriginY,
                boundingFrameWidth: self.boundingFrameWidth,
                boundingFrameHeight: self.boundingFrameHeight,
                gallery: owner.gallery,
                tool: owner.tool,
                tab: owner.tab,
                map: owner.map,
                game: owner.game
            )
        }
    }
}
