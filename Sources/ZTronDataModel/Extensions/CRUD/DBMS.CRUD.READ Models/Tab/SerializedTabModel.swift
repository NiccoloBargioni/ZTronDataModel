import Foundation
import SQLite3
import SQLite

/// - `TAB(name, position, iconName, map, game)`
public final class SerializedTabModel: Hashable, Sendable, ObservableObject {
    private let name: String
    private let position: Int
    private let map: String
    private let game: String
    
    internal init(
        name: String,
        position: Int,
        map: String,
        game: String
    ) {
        self.name = name
        self.position = position
        self.map = map
        self.game = game
    }
    
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let tab = DBMS.tab
        
        self.name = namespaceColumns ? fromRow[tab.table[tab.nameColumn]] :  fromRow[tab.nameColumn]
        self.position = namespaceColumns ? fromRow[tab.table[tab.positionColumn]] : fromRow[tab.positionColumn]
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
            

    public func getGame() -> String {
        return self.game
    }
    
    public func toString() -> String {
        return """
        TAB(
            name: \(self.name),
            position: \(self.position),
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
        
        internal init(from: SerializedTabModel) {
            self.owner = from
            self.position = from.getPosition()
        }
        
        public final func withUpdatedPosition(_ newPosition: Int) -> WritableDraft {
            self.position = newPosition
            return self
        }
        
        public final func getPosition() -> Int {
            return self.position
        }
        
        public final func getImmutableCopy() -> SerializedTabModel {
            guard let owner = self.owner else { fatalError("Failed to retain reference to mutable parent of type \(String(describing: SerializedTabModel.self))") }
            return SerializedTabModel(
                name: owner.name,
                position: owner.position,
                map: owner.map,
                game: owner.game
            )
        }
    }

}
