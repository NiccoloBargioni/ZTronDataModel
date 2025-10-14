import Foundation
import SQLite3
import SQLite


/// - `GAME(name, position, assetsImageName, studio)`
/// - `PK(name)`
/// - `FK(studio) REFERENCES STUDIO(name) ON DELETE CASCADE ON UPDATE CASCADE`
public final class SerializedGameModel: ReadGameOptional, ObservableObject {
    private let name: String
    private let position: Int
    private let assetsImageName: String
    private let studio: String
    
    internal init(_ fromRow: Row, namespaceColumns: Bool = false) {
        let game = DBMS.game
        
        self.name = (namespaceColumns) ? fromRow[game.table[game.nameColumn]] : fromRow[game.nameColumn]
        self.position = (namespaceColumns) ? fromRow[game.table[game.positionColumn]] : fromRow[game.positionColumn]
        self.assetsImageName = (namespaceColumns) ? fromRow[game.table[game.assetsImageNameColumn]] : fromRow[game.assetsImageNameColumn]
        self.studio = (namespaceColumns) ? fromRow[game.table[game.foreignKeys.studioColumn]] : fromRow[game.foreignKeys.studioColumn]
    }
    
    internal init(
        name: String,
        position: Int,
        assetsImageName: String,
        studio: String
    ) {
        self.name = name
        self.position = position
        self.studio = studio
        self.assetsImageName = assetsImageName
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.studio)
    }
    
    public static func == (lhs: SerializedGameModel, rhs: SerializedGameModel) -> Bool {
        return lhs.name == rhs.name && lhs.position == rhs.position && lhs.assetsImageName == rhs.assetsImageName &&
            lhs.studio == rhs.studio
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
    
    public func getStudio() -> String {
        return self.studio
    }

    
    public func toString() -> String {
        return """
        GAME(
            name: \(self.name),
            position: \(self.position),
            assetsImageName: \(self.assetsImageName),
            studio: \(self.studio)
        )
        """
    }
    
    public final func getMutableCopy() -> WritableDraft {
        return Self.WritableDraft(from: self)
    }
    
    public final class WritableDraft {
        weak private var owner: SerializedGameModel?
        private var position: Int
        private var assetsImageName: String
        
        private var didPositionUpdate: Bool = false
        private var didAssetsImageNameUpdate: Bool = false
        
        internal init(from: SerializedGameModel) {
            self.owner = from
            self.position = from.position
            self.assetsImageName = from.assetsImageName
        }
        
        public final func withUpdatedPosition(_ newPosition: Int) -> WritableDraft {
            if newPosition != self.position {
                self.position = newPosition
                self.didPositionUpdate = true
            }
            return self
        }
        
        public final func getPosition() -> Int {
            return self.position
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
        
        public final func withAssetsImageName(_ assetsImageName: String) -> Self {
            if self.assetsImageName != assetsImageName {
                self.assetsImageName = assetsImageName.lowercased()
                self.didAssetsImageNameUpdate = true
            }
            return self
        }
        
        internal final func didAssetsImageNameChange() -> Bool {
            return self.didAssetsImageNameUpdate
        }

        public final func getAssetsImageName() -> String {
            return self.assetsImageName
        }

        public final func getPreviousAssetsImageName() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `assetsImageName`.")
            }
            return owner.assetsImageName
        }
        
        
        public final func getName() -> String {
            guard let owner = self.owner else {
                fatalError("Unable to retain reference of master before reading `name`.")
            }
            return owner.name
        }

        
        internal final func getImmutableCopy() -> SerializedGameModel {
            guard let owner = self.owner else { fatalError("Failed to retain reference to mutable parent of type \(String(describing: SerializedGameModel.self))") }
            
            return SerializedGameModel(
                name: owner.getName(),
                position: self.position,
                assetsImageName: self.assetsImageName,
                studio: owner.getStudio()
            )
        }
    }

}
