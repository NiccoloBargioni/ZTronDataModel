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
    
    public final func getMutableCopy() -> SerializedOutlineModel.WritableDraft {
        return .init(from: self)
    }
    
    public final class WritableDraft {
        private var resourceName: String
        private var colorHex: String
        private var _isActive: Bool
        private var opacity: Double
        private var boundingBox: CGRect
        weak private var owner: SerializedOutlineModel?
        
        private var didResourceNameUpdate: Bool = false
        private var didColorHexUpdate: Bool = false
        private var didIsActiveUpdate: Bool = false
        private var didOpacityUpdate: Bool = false
        private var didBoundingBoxUpdate: Bool = false


        
        fileprivate init(from: SerializedOutlineModel) {
            self.colorHex = from.colorHex
            self._isActive = from._isActive
            self.opacity = from.opacity
            self.boundingBox = from.boundingBox
            self.resourceName = from.resourceName
            self.owner = from
        }
        
        public final func withResourceName(_ resourceName: String) -> Self {
            if self.resourceName != resourceName {
                self.resourceName = resourceName.lowercased()
                self.didResourceNameUpdate = true
            }
            
            return self
        }
        
        internal final func didResourceNameChange() -> Bool {
            return self.didResourceNameUpdate
        }
        
        public final func getResourceName() -> String {
            return self.resourceName
        }
        
        public final func withColorHex(_ colorHex: String) -> Self {
            if self.colorHex != colorHex {
                assert(isValidHexColor(colorHex))
                self.colorHex = colorHex
                self.didColorHexUpdate = true
            }
            return self
        }
        
        internal final func didColorHexChange() -> Bool {
            return self.didColorHexUpdate
        }
        
        public final func getColorHex() -> String {
            return self.colorHex
        }

        public final func getPreviousColorHex() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `colorHex`.")
            }
            return owner.colorHex
        }

        public final func withIsActive(_ isActive: Bool) -> Self {
            if self._isActive != isActive {
                self._isActive = isActive
                self.didIsActiveUpdate = true
            }
            return self
        }
        
        internal final func didIsActiveChange() -> Bool {
            return self.didIsActiveUpdate
        }
        
        public final func isActive() -> Bool {
            return self._isActive
        }

        public final func getPreviousIsActive() -> Bool {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `isActive`.")
            }
            return owner._isActive
        }
        
        public final func withOpacity(_ opacity: Double) -> Self {
            if self.opacity != opacity {
                assert(opacity >= 0 && opacity <= 1)
                self.opacity = opacity
                self.didOpacityUpdate = true
            }
            return self
        }
        
        internal final func didOpacityChange() -> Bool {
            return self.didOpacityUpdate
        }
        
        public final func getOpacity() -> Double {
            return self.opacity
        }

        public final func getPreviousOpacity() -> Double {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `opacity`.")
            }
            return owner.opacity
        }
        
        public final func withBoundingBox(_ boundingBox: CGRect) -> Self {
            if boundingBox.origin.x != self.boundingBox.origin.x ||
                boundingBox.origin.y != self.boundingBox.origin.y ||
                boundingBox.size.width != self.boundingBox.size.width ||
                boundingBox.size.height != self.boundingBox.size.height {
                
                self.boundingBox = boundingBox
                self.didBoundingBoxUpdate = true
            }
            
            return self
        }
        
        internal final func didBoundingBoxChange() -> Bool {
            return self.didBoundingBoxUpdate
        }
        
        
        public final func getPreviousBoundingBox() -> CGRect {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `bounding box`.")
            }
            return owner.boundingBox
        }

        
        public final func getBoundingBox() -> CGRect {
            return self.boundingBox
        }

        public final func getImage() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `image`.")
            }
            return owner.image
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
        
        internal final func getImmutableCopy() -> SerializedOutlineModel {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before committing draft.")
            }
            
            return .init(
                resourceName: self.resourceName,
                colorHex: self.colorHex,
                isActive: self._isActive,
                opacity: self.opacity,
                boundingBoxOriginXColumn: self.boundingBox.origin.x,
                boundingBoxOriginYColumn: self.boundingBox.origin.y,
                boundingBoxWidthColumn: self.boundingBox.size.width,
                boundingBoxHeightColumn: self.boundingBox.size.height,
                image: owner.image,
                gallery: owner.game,
                tool: owner.tool,
                tab: owner.tab,
                map: owner.map,
                game: owner.game
            )
        }
    }
}
