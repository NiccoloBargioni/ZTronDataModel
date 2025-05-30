import Foundation
import SQLite3
import SQLite

/// - `TAB(name, position, iconName, map, game)`
public final class SerializedTabModelWithTools: ObservableObject {
    private let name: String
    private let position: Int
    private let map: String
    private let game: String
    private let tools: [SerializedToolModel]
    
    private init(
        name: String,
        position: Int,
        map: String,
        game: String,
        tools: [SerializedToolModel]
    ) {
        self.name = name
        self.position = position
        self.map = map
        self.game = game
        self.tools = tools
    }
    
    internal init(
        tabModel: SerializedTabModel,
        tools: [SerializedToolModel]
    ) {
        self.name = tabModel.getName()
        self.position = tabModel.getPosition()
        self.map = tabModel.getMap()
        self.game = tabModel.getGame()
        self.tools = tools
    }
        
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.game)
    }
    
    public static func == (lhs: SerializedTabModelWithTools, rhs: SerializedTabModelWithTools) -> Bool {
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
    
    public final func getTools() -> [SerializedToolModel] {
        return self.tools
    }
    
    public func toString() -> String {
        return """
        TAB(
            name: \(self.name),
            position: \(self.position),
            map: \(self.map),
            game: \(self.game),
            tools: \(self.tools.reduce("", { toolsToString, thisTool in
                return toolsToString.appending(thisTool.toString()).appending("\n\n")
            }))
        )
        """
    }
    
    public final func getMutableCopy() -> WritableDraft {
        return Self.WritableDraft(from: self)
    }
    
    public final class WritableDraft {
        weak private var owner: SerializedTabModelWithTools?
        private var position: Int
        
        internal init(from: SerializedTabModelWithTools) {
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
        
        public final func getImmutableCopy() -> SerializedTabModelWithTools {
            guard let owner = self.owner else { fatalError("Failed to retain reference to mutable parent of type \(String(describing: SerializedTabModelWithTools.self))") }
            return SerializedTabModelWithTools(
                name: owner.name,
                position: owner.position,
                map: owner.map,
                game: owner.game,
                tools: owner.tools
            )
        }
    }

}
