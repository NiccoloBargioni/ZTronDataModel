import Foundation

public final class AnySerializedVisualMediaModel: SerializedVisualMediaModel {
    public typealias WD = AnyWritableDraft
    
    private let base: any SerializedVisualMediaModel
    private let name: String?
    private let description: String?
    private let position: Int?
    private let searchLabel: String?
    
    
    internal init(
        _ base: any SerializedVisualMediaModel,
    ) {
        self.base = base
        self.name = nil
        self.description = nil
        self.position = nil
        self.searchLabel = nil
    }
    
    private init(
        base: any SerializedVisualMediaModel,
        name: String,
        description: String,
        position: Int,
        searchLabel: String?,
    ) {
        self.base = base
        self.name = name.lowercased()
        self.description = description.lowercased()
        self.position = position
        self.searchLabel = searchLabel?.lowercased()
    }
    
    public func getName() -> String {
        return self.name ?? base.getName()
    }
    
    public func getDescription() -> String {
        return self.description ?? base.getDescription()
    }
    
    public func getPosition() -> Int {
        return self.position ?? base.getPosition()
    }
    
    public func getSearchLabel() -> String? {
        return self.searchLabel ?? base.getSearchLabel()
    }
    
    public func getGallery() -> String {
        return base.getGallery()
    }
    
    public func getTool() -> String {
        return base.getTool()
    }
    
    public func getTab() -> String {
        return base.getTab()
    }
    
    public func getMap() -> String {
        return base.getMap()
    }
    
    public func getGame() -> String {
        return base.getGame()
    }
    
    public func getType() -> VisualMediaType {
        return base.getType()
    }
    
    public func toString() -> String {
        return base.toString()
    }

    
    public static func == (lhs: AnySerializedVisualMediaModel, rhs: AnySerializedVisualMediaModel) -> Bool {
        return lhs.getName() == rhs.getName() && lhs.getGame() == rhs.getGame() && lhs.getMap() == rhs.getMap() && lhs.getTab() == rhs.getTab() && lhs.getTool() == rhs.getTool()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(base.getName())
        hasher.combine(base.getMap())
    }
    
    public final func getMutableCopy() -> AnySerializedVisualMediaModel.AnyWritableDraft {
        return .init(fromParent: self)
    }
 
    public final class AnyWritableDraft: SerializedVisualMediaModelWritableDraft {
        public func getPreviousDescription() -> String {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before committing draft.") }
            return owner.description!
        }
        
        public func getPreviousPosition() -> Int {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before committing draft.") }
            return owner.position!
        }
        
        public func getPreviousSearchLabel() -> String? {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before committing draft.") }
            return owner.searchLabel!
        }
        
        
        public func getImmutableCopy() -> AnySerializedVisualMediaModel {
            guard let owner = self.owner else {
                fatalError("Attempted to get immutable copy in \(String(describing: Self.self)) but owner referenced was released before immutable copy could be created.")
            }
            return AnySerializedVisualMediaModel(
                base: owner,
                name: self.name,
                description: self.description,
                position: self.position,
                searchLabel: self.searchLabel,
            )
        }
        
        public typealias M = AnySerializedVisualMediaModel
        private var name: String
        private var description: String
        private var position: Int
        private var searchLabel: String?
        weak private var owner: AnySerializedVisualMediaModel?

        private init(
            name: String,
            description: String,
            position: Int,
            searchLabel: String? = nil,
            owner: AnySerializedVisualMediaModel
        ) {
            self.name = name
            self.description = description
            self.position = position
            self.searchLabel = searchLabel
            self.owner = owner
        }
        
        internal convenience init(fromParent: AnySerializedVisualMediaModel) {
            self.init(
                name: fromParent.getName(),
                description: fromParent.getDescription(),
                position: fromParent.getPosition(),
                owner: fromParent
            )
        }
        
        public func withName(_ name: String) -> Self {
            self.name = name.lowercased()
            return self
        }
        
        public func getPreviousName() -> String {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before committing draft.") }
            return owner.getName()
        }

        
        public func withDescription(_ description: String) -> Self {
            self.description = description.lowercased()
            return self
        }
        
        public func withPosition(_ position: Int) -> Self {
            self.position = position
            return self
        }
        
        public func withSearchLabel(_ searchLabel: String?) -> Self {
            self.searchLabel = searchLabel?.lowercased()
            return self
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
    }
}

