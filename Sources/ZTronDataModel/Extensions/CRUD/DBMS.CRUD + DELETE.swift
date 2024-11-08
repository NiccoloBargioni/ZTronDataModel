import Foundation
import SQLite3
import SQLite

#if DEBUG
public extension DBMS.CRUD {
    
    static func deleteStudio(for dbConnection: Connection, studio: String) throws {
        let studioModel = DomainModel.studio
        
        try dbConnection.run(
            studioModel.table.filter(studioModel.nameColumn == studio).delete()
        )
    }
    
    static func deleteGame(for dbConnection: Connection, game: String, studio: String) throws {
        let gameModel = DomainModel.game
        
        try dbConnection.run(
            gameModel.table.filter(gameModel.nameColumn == game && gameModel.foreignKeys.studioColumn == studio).delete()
        )
    }
}
#endif
