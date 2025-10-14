import Foundation
import SQLite3
import SQLite

/// - `TOOL(name, position, assetsImageName, tab, map, game)`
public final class SerializedToolModel: Hashable, Sendable, ObservableObject {
    private let name: String
    private let position: Int
    private let assetsImageName: String
    private let tab: String
    private let map: String
    private let game: String
    
    internal init(
        name: String,
        position: Int,
        assetsImageName: String,
        tab: String,
        map: String,
        game: String
    ) {
        self.name = name
        self.position = position
        self.assetsImageName = assetsImageName
        self.tab = tab
        self.map = map
        self.game = game
    }
    
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let tool = DBMS.tool
        
        self.name = namespaceColumns ? fromRow[tool.table[tool.nameColumn]] :  fromRow[tool.nameColumn]
        self.position = namespaceColumns ? fromRow[tool.table[tool.positionColumn]] : fromRow[tool.positionColumn]
        self.assetsImageName = namespaceColumns ? fromRow[tool.table[tool.assetsImageNameColumn]] : fromRow[tool.assetsImageNameColumn]
        self.tab = namespaceColumns ? fromRow[tool.table[tool.foreignKeys.tabColumn]] : fromRow[tool.foreignKeys.tabColumn]
        self.map = namespaceColumns ? fromRow[tool.table[tool.foreignKeys.mapColumn]] : fromRow[tool.foreignKeys.mapColumn]
        self.game = namespaceColumns ? fromRow[tool.table[tool.foreignKeys.gameColumn]] : fromRow[tool.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.tab)
        hasher.combine(self.map)
        hasher.combine(self.game)
    }
    
    public static func == (lhs: SerializedToolModel, rhs: SerializedToolModel) -> Bool {
        return lhs.name == rhs.name &&
                lhs.position == rhs.position &&
                lhs.assetsImageName == rhs.assetsImageName &&
                lhs.map == rhs.map &&
                lhs.tab == rhs.tab &&
                lhs.game == rhs.game
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getPosition() -> Int {
        return self.position
    }
    
    public func getAssetsImageName() -> String {
        return self.assetsImageName
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
    
    public func toString() -> String {
        return """
        TOOL(
            name: \(self.name),
            position: \(self.position),
            assetsImageName: \(self.assetsImageName),
            tab: \(self.tab),
            map: \(self.map),
            game: \(self.game)
        )
        """
    }
    
    public final func getMutableCopy() -> WritableDraft {
        return Self.WritableDraft(from: self)
    }
    
    public final class WritableDraft {
        weak private var owner: SerializedToolModel?
        private var position: Int
        private var name: String
        private var assetsImageName: String
        private var tab: String
        
        private var didPositionUpdate: Bool = false
        private var didNameUpdate: Bool = false
        private var didAssetsImageNameUpdate: Bool = false
        private var didTabUpdate: Bool = false
        
        internal init(from: SerializedToolModel) {
            self.owner = from
            self.position = from.getPosition()
            self.name = from.getName()
            self.assetsImageName = from.getAssetsImageName()
            self.tab = from.getTab()
        }
        
        @discardableResult public final func withUpdatedPosition(_ newPosition: Int) -> WritableDraft {
            if self.position != newPosition {
                self.position = newPosition
                self.didPositionUpdate = true
            }
            return self
        }
        
        internal final func didPositionChange() -> Bool {
            return self.didPositionUpdate
        }
        
        public final func getPreviousPosition() -> Int {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `position`.")
            }
            return owner.position
        }
        
        @discardableResult public final func withName(_ newName: String) -> Self {
            if self.name != newName {
                self.name = newName.lowercased()
                self.didNameUpdate = true
            }
            return self
        }
        
        internal final func didNameChange() -> Bool {
            return self.didNameUpdate
        }
        
        public final func getPreviousName() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `name`.")
            }
            return owner.name
        }

        
        @discardableResult public final func withAssetsImageName(_ newAssetsImageName: String) -> Self {
            if self.assetsImageName != newAssetsImageName {
                self.assetsImageName = newAssetsImageName
                self.didAssetsImageNameUpdate = true
            }
            return self
        }
        
        internal final func didAssetsImageNameChange() -> Bool {
            return self.didAssetsImageNameUpdate
        }
        
        public final func getPreviousAssetsImageName() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `assetsImageName`.")
            }
            return owner.assetsImageName
        }
        
        @discardableResult public final func withTab(_ newTab: String) -> Self {
            if self.tab != newTab {
                self.tab = newTab.lowercased()
                self.didTabUpdate = true
            }
            return self
        }
        
        internal final func didTabChange() -> Bool {
            return self.didTabUpdate
        }
        
        internal final func getPreviousTab() -> String {
            guard let owner = self.owner else { fatalError("Failed to retain reference to original copy before committing draft.") }
            return owner.getTab()
        }
        
        public final func getTab() -> String {
            return self.tab
        }
        
        public final func getPosition() -> Int {
            return self.position
        }
        
        public final func getName() -> String {
            return self.name
        }
                
        public final func getAssetsImageName() -> String {
            return self.assetsImageName
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

        
        internal final func getImmutableCopy() -> SerializedToolModel {
            guard let owner = self.owner else { fatalError("Failed to retain reference to mutable parent of type \(String(describing: SerializedToolModel.self))") }
            return SerializedToolModel(
                name: self.name,
                position: self.position,
                assetsImageName: self.assetsImageName,
                tab: self.tab,
                map: owner.map,
                game: owner.game
            )
        }
    }

}
