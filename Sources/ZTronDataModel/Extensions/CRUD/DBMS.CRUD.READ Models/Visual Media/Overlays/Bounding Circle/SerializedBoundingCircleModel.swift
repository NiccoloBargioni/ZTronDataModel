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
    
    public final func getMutableCopy() -> SerializedBoundingCircleModel.WritableDraft {
        return .init(from: self)
    }
    
    public final class WritableDraft {
        private var colorHex: String
        private var _isActive: Bool
        private var opacity: Double
        private var idleDiameter: Double?
        private var normalizedCenter: CGPoint?
        weak private var owner: SerializedBoundingCircleModel?
        
        private var didColorHexUpdate: Bool = false
        private var didIsActiveUpdate: Bool = false
        private var didOpacityUpdate: Bool = false
        private var didIdleDiameterUpdate: Bool = false
        private var didNormalizedCenterUpdate: Bool = false

        
        fileprivate init(from: SerializedBoundingCircleModel) {
            self.colorHex = from.colorHex
            self._isActive = from._isActive
            self.opacity = from.opacity
            self.idleDiameter = from.idleDiameter
            self.normalizedCenter = from.normalizedCenter
            self.owner = from
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
        
        public final func getPreviousColorHex() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `colorHex`.")
            }
            return owner.colorHex
        }
        
        public final func getColorHex() -> String {
            return self.colorHex
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
        
        public final func getPreviousIsActive() -> Bool {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `isActive`.")
            }
            return owner._isActive
        }

        public final func isActive() -> Bool {
            return self._isActive
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
        
        public final func getPreviousOpacity() -> Double {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `opacity`.")
            }
            return owner.opacity
        }
        
        public final func getOpacity() -> Double {
            return self.opacity
        }

        
        public final func withIdleDiameter(_ diameter: Double?) -> Self {
            if self.idleDiameter != idleDiameter {
                assert(diameter ?? 0 >= 0 && diameter ?? 0 <= 1)
                self.idleDiameter = diameter
                self.didIdleDiameterUpdate = true
            }
            return self
        }
        
        internal final func didIdleDiameterChange() -> Bool {
            return self.didIdleDiameterUpdate
        }
        
        
        public final func getIdleDiameter() -> Double? {
            return self.idleDiameter
        }

        public final func getPreviousIdleDiameter() -> Double? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `idle diameter`.")
            }
            return owner.idleDiameter
        }
        
        public final func withNormalizedCenter(_ center: CGPoint?) -> Self {
            if self.normalizedCenter?.x != center?.x || self.normalizedCenter?.y != center?.y {
                assert(center?.x ?? 0 >= 0 && center?.x ?? 0 <= 1)
                assert(center?.y ?? 0 >= 0 && center?.y ?? 0 <= 1)
                
                self.normalizedCenter = center
                
                self.didNormalizedCenterUpdate = true
            }
            return self
        }
        
        internal final func didNormalizedCenterChange() -> Bool {
            return self.didNormalizedCenterUpdate
        }
        
        
        public final func getNormalizedCenter() -> CGPoint? {
            return self.normalizedCenter
        }
        
        
        public final func getPreviousNormalizedCenter() -> CGPoint? {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `normalized center`.")
            }
            return owner.normalizedCenter
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
        
        internal final func getImmutableCopy() -> SerializedBoundingCircleModel {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before committing draft.")
            }
            
            return .init(
                colorHex: self.colorHex,
                isActive: self._isActive,
                opacity: self.opacity,
                idleDiameter: self.idleDiameter,
                normalizedCenterX: self.normalizedCenter?.x,
                normalizedCenterY: self.normalizedCenter?.y,
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





/// Validates an String as an hex color.
///
/// A string is considered to be a valid color hex if it meets all the following conditions:
/// - It starts with `#`
/// - The `#` is followed by either 3 or 6 characters
/// - All of the latter are valid hex digits.
///
/// - Returns: `true` if `hex` is a valid color hex string representation, `false` otherwise
/// - Parameter hex: The string to validate
/// - Complexity: O(hex.count) if `hex` is a valid
internal func isValidHexColor(_ hex: String) -> Bool {
    if hex.first != "#" {
        return false
    } else {
        if hex.count != 4 && hex.count != 7 {
            return false
        } else {
            var expectedFirstHexDigitIndex = hex.startIndex
            _ = hex.formIndex(&expectedFirstHexDigitIndex, offsetBy: 1, limitedBy: hex.endIndex)
            return hex.suffix(from: expectedFirstHexDigitIndex).allSatisfy(\.isHexDigit)
        }
    }
}
