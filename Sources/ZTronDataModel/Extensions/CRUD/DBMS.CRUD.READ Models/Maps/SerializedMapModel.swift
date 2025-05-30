import Foundation
import SQLite3
import SQLite

/// - `MAP(name, position, assetsImageName, game)`
/// - `PK(name, game)`
/// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
public final class SerializedMapModel: ReadMapOptional, ObservableObject {
    private let name: String
    private let position: Int
    private let assetsImageName: String?
    private let game: String
    
    internal init(
        name: String,
        position: Int,
        assetsImageName: String?,
        game: String
    ) {
        self.name = name
        self.position = position
        self.assetsImageName = assetsImageName
        self.game = game
    }
    
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let map = DBMS.map
        
        self.name = namespaceColumns ? fromRow[map.table[map.nameColumn]] :  fromRow[map.nameColumn]
        self.position = namespaceColumns ? fromRow[map.table[map.positionColumn]] : fromRow[map.positionColumn]
        self.assetsImageName = namespaceColumns ? fromRow[map.table[map.assetsImageNameColumn]] : fromRow[map.assetsImageNameColumn]
        self.game = namespaceColumns ? fromRow[map.table[map.foreignKeys.gameColumn]] : fromRow[map.foreignKeys.gameColumn]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.game)
    }
    
    public static func == (lhs: SerializedMapModel, rhs: SerializedMapModel) -> Bool {
        return lhs.name == rhs.name && lhs.game == rhs.game && lhs.position == rhs.position && lhs.assetsImageName == rhs.assetsImageName
    }
    
    public func getName() -> String {
        return self.name
    }
        
    public func getPosition() -> Int {
        return self.position
    }
    
    public func getAssetsImageName() -> String? {
        return self.assetsImageName
    }
            
    public func getGame() -> String {
        return self.game
    }
    
    public func toString() -> String {
        return """
        MAP(
            name: \(self.name),
            position: \(self.position),
            assetsImageName: \(self.assetsImageName ?? "nil"),
            game: \(self.game)
        )
        """
    }
    
    public final func getMutableCopy() -> WritableDraft {
        return Self.WritableDraft(from: self)
    }
    
    public final class WritableDraft {
        weak private var owner: SerializedMapModel?
        private var position: Int
        
        internal init(from: SerializedMapModel) {
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
        
        public final func getImmutableCopy() -> SerializedMapModel {
            guard let owner = self.owner else { fatalError("Failed to retain reference to mutable parent of type \(String(describing: SerializedGameModel.self))") }
            return SerializedMapModel(
                name: owner.getName(),
                position: self.position,
                assetsImageName: owner.getAssetsImageName(),
                game: owner.getGame()
            )
        }
    }

}
