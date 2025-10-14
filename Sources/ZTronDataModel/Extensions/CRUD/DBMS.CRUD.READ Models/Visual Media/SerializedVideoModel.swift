import Foundation
import SQLite3
import SQLite


/// - `VISUAL_MEDIA(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
public final class SerializedVideoModel: SerializedVisualMediaModel {
    private let name: String
    private let description: String
    private let position: Int
    private let searchLabel: String?
    private let gallery: String
    private let tool: String
    private let tab: String
    private let map: String
    private let game: String
    private let `extension`: String
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let image = DBMS.visualMedia

        guard let `extension` = (namespaceColumns) ? fromRow[image.table[image.extensionColumn]] : fromRow[image.extensionColumn] else {
            fatalError("Unexpectedly found empty extension for video \((namespaceColumns) ? fromRow[image.table[image.nameColumn]] : fromRow[image.nameColumn])")
        }

                
        self.name = (namespaceColumns) ? fromRow[image.table[image.nameColumn]] : fromRow[image.nameColumn]
        self.description = (namespaceColumns) ? fromRow[image.table[image.descriptionColumn]] : fromRow[image.descriptionColumn]
        self.position = (namespaceColumns) ? fromRow[image.table[image.positionColumn]] : fromRow[image.positionColumn]
        self.searchLabel = (namespaceColumns) ? fromRow[image.table[image.searchLabelColumn]] : fromRow[image.searchLabelColumn]
        self.gallery = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.galleryColumn]] : fromRow[image.foreignKeys.galleryColumn]
        self.tool = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.toolColumn]] : fromRow[image.foreignKeys.toolColumn]
        self.tab = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.tabColumn]] : fromRow[image.foreignKeys.tabColumn]
        self.map = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.mapColumn]] : fromRow[image.foreignKeys.mapColumn]
        self.game = (namespaceColumns) ? fromRow[image.table[image.foreignKeys.gameColumn]] : fromRow[image.foreignKeys.gameColumn]
        self.extension = `extension`
    }
    
    internal init(
        name: String,
        extension: String,
        description: String,
        position: Int,
        searchLabel: String?,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.name = name
        self.description = description
        self.position = position
        self.searchLabel = searchLabel
        self.gallery = gallery
        self.tool = tool
        self.tab = tab
        self.map = map
        self.game = game
        self.extension = `extension`
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.gallery)
    }
    
    public static func == (lhs: SerializedVideoModel, rhs: SerializedVideoModel) -> Bool {
        return lhs.name == rhs.name && lhs.gallery == rhs.gallery && lhs.tool == rhs.tool &&
        lhs.tab == rhs.tab && lhs.map == rhs.map && lhs.game == rhs.game && lhs.extension == rhs.extension
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getDescription() -> String {
        return self.description
    }
    
    public func getPosition() -> Int {
        return self.position
    }
    
    public func getSearchLabel() -> String? {
        return self.searchLabel
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
    
    public func getType() -> VisualMediaType {
        return .video
    }
    
    public func getExtension() -> String {
        return self.extension
    }
    
    public func toString() -> String {
        return """
        VISUAL_MEDIA(
            type: video,
            extension: \(self.extension),
            name: \(self.name),
            description: \(self.description),
            position: \(self.position),
            searchLabel: \(String(describing: self.searchLabel)),
            gallery: \(self.gallery),
            tool: \(self.tool),
            tab: \(self.tab),
            map: \(self.map),
            game: \(self.game)
        )
        """
    }
    
    public func getMutableCopy() -> WritableDraft {
        return SerializedVideoModel.WritableDraft(fromParent: self)
    }

    
    public final class WritableDraft: SerializedVisualMediaModelWritableDraft {
        public typealias M = SerializedVideoModel
        
        private var name: String
        private var description: String
        private var position: Int
        private var searchLabel: String?
        weak private var owner: SerializedVideoModel?

        
        private(set) fileprivate var didNameChange: Bool = false
        private(set) fileprivate var didDescriptionChange: Bool = false
        private(set) fileprivate var didPositionChange: Bool = false
        private(set) fileprivate var didSearchLabelChange: Bool = false

        
        private init(
            name: String,
            description: String,
            position: Int,
            searchLabel: String? = nil,
            owner: SerializedVideoModel
        ) {
            self.name = name
            self.description = description
            self.position = position
            self.searchLabel = searchLabel
            self.owner = owner
        }
        
        fileprivate convenience init(fromParent: SerializedVideoModel) {
            self.init(
                name: fromParent.name,
                description: fromParent.description,
                position: fromParent.position,
                searchLabel: fromParent.searchLabel,
                owner: fromParent
            )
        }
        
        @discardableResult public final func withName(_ name: String) -> WritableDraft {
            if self.name != name {
                self.name = name.lowercased()
                self.didNameChange = true
            }
            return self
        }
        
        internal final func didNameUpdate() -> Bool {
            return self.didNameChange
        }
        
        public final func getName() -> String {
            return self.name
        }
        
        public final func getPreviousName() -> String {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before committing draft.") }
            return owner.getName()
        }
        
        @discardableResult public final func withDescription(_ description: String) -> WritableDraft {
            if self.description != description {
                self.description = description.lowercased()
                self.didDescriptionChange = true
            }
            return self
        }
        
        internal final func didDescriptionUpdate() -> Bool {
            return self.didDescriptionChange
        }
        
        public final func getPreviousDescription() -> String {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before fetching `description`.") }
            return owner.description
        }

        
        public final func getDescription() -> String {
            return self.description
        }
        
        @discardableResult public final func withPosition(_ position: Int) -> WritableDraft {
            if self.position != position {
                self.position = position
                self.didPositionChange = true
            }
            return self
        }
        
        internal final func didPositionUpdate() -> Bool {
            return self.didPositionChange
        }
        
        public final func getPosition() -> Int {
            return self.position
        }
        
        public final func getPreviousPosition() -> Int {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before fetching `position`.") }
            return owner.position
        }
        
        @discardableResult public final func withSearchLabel(_ searchLabel: String?) -> WritableDraft {
            if self.searchLabel != searchLabel {
                self.searchLabel = searchLabel?.lowercased()
                self.didSearchLabelChange = true
            }
            return self
        }
        
        internal final func didSearchLabelUpdate() -> Bool {
            return self.didSearchLabelChange
        }
        
        public final func getPreviousSearchLabel() -> String? {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before fetching `searchLabel`.") }
            return owner.searchLabel
        }
        
        public final func getSearchLabel() -> String? {
            return self.searchLabel
        }
        
        /// - Note: Unsafe. One could make an immutable copy from this and pass it around as if it was fetched from db.
        public final func getImmutableCopy() -> SerializedVideoModel {
            guard let owner = self.owner else {
                fatalError("Unexpectedly released reference to parent before returning immutable copy")
            }
            
            return SerializedVideoModel(
                name: self.name,
                extension: owner.extension,
                description: self.description,
                position: self.position,
                searchLabel: self.searchLabel,
                gallery: owner.gallery,
                tool: owner.tool,
                tab: owner.tab,
                map: owner.map,
                game: owner.game
            )
        }
    }
    
    
}

extension SerializedVideoModel.WritableDraft: SerializedVisualMediaModelWritableDraftUpdateBearer {
    
}
