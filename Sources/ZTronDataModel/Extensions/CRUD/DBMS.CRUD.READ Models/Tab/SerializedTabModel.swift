import Foundation
import SQLite3
import SQLite

/// - `TAB(name, position, iconName, map, game)`
public final class SerializedTabModel: Hashable, Sendable, ObservableObject {
    private let name: String
    private let position: Int
    private let rating: Int
    private let map: String
    private let game: String
    
    internal init(
        name: String,
        position: Int,
        rating: Int,
        map: String,
        game: String
    ) {
        self.name = name
        self.position = position
        self.rating = rating
        self.map = map
        self.game = game
    }
    
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let tab = DBMS.tab
        
        self.name = namespaceColumns ? fromRow[tab.table[tab.nameColumn]] :  fromRow[tab.nameColumn]
        self.position = namespaceColumns ? fromRow[tab.table[tab.positionColumn]] : fromRow[tab.positionColumn]
        self.rating = namespaceColumns ? fromRow[tab.table[tab.ratingColumn]] : fromRow[tab.ratingColumn]
        self.map = namespaceColumns ? fromRow[tab.table[tab.foreignKeys.mapColumn]] : fromRow[tab.foreignKeys.mapColumn]
        self.game = namespaceColumns ? fromRow[tab.table[tab.foreignKeys.gameColumn]] : fromRow[tab.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.game)
    }
    
    public static func == (lhs: SerializedTabModel, rhs: SerializedTabModel) -> Bool {
        return lhs.name == rhs.name &&
                lhs.position == rhs.position &&
                lhs.rating == rhs.rating &&
                lhs.map == rhs.map &&
                lhs.game == rhs.game
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getPosition() -> Int {
        return self.position
    }
    
    
    public func getMap() -> String {
        return self.map
    }
    
    public func getRating() -> Int {
        return self.rating
    }
            

    public func getGame() -> String {
        return self.game
    }
    
    public func toString() -> String {
        return """
        TAB(
            name: \(self.name),
            position: \(self.position),
            rating: \(self.rating),
            map: \(self.map),
            game: \(self.game)
        )
        """
    }
    
    public final func getMutableCopy() -> WritableDraft {
        return Self.WritableDraft(from: self)
    }
    
    public final class WritableDraft {
        weak private var owner: SerializedTabModel?
        private var position: Int
        private var name: String
        private var rating: Int
        
        private var didPositionUpdate: Bool = false
        private var didNameUpdate: Bool = false
        private var didRatingUpdate: Bool = false
        
        internal init(from: SerializedTabModel) {
            self.owner = from
            self.position = from.getPosition()
            self.name = from.getName()
            self.rating = from.rating
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
        
        
        @discardableResult public final func withName(_ name: String) -> Self {
            if self.name != name {
                self.name = name.lowercased()
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
        
        
        @discardableResult public final func withRating(_ rating: Int) -> Self {
            assert(rating >= 0 && rating <= 3)
            
            if self.rating != rating {
                self.rating = rating
                self.didRatingUpdate = true
            }
            return self
        }
        
        public final func getRating() -> Int {
            return self.rating
        }
        
        internal final func didRatingChange() -> Bool {
            return self.didRatingUpdate
        }
        
        
        public final func getPosition() -> Int {
            return self.position
        }
        
        
        public final func getName() -> String {
            return self.name
        }
        
        
        public final func getGame() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `game`.")
            }
            return owner.game
        }

        public final func getMap() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `map`.")
            }
            return owner.map
        }

        internal final func getImmutableCopy() -> SerializedTabModel {
            guard let owner = self.owner else { fatalError("Failed to retain reference to mutable parent of type \(String(describing: SerializedTabModel.self))") }
            
            return SerializedTabModel(
                name: self.name,
                position: self.position,
                rating: self.rating,
                map: owner.map,
                game: owner.game
            )
        }
    }

}
