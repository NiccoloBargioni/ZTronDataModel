import XCTest
import SQLite
import SQLite3
@testable import ZTronDataModel


final class DraftModelTests: XCTestCase {
    
    // MARK: - TEST GAME UPDATES
    public final func testGameWritableDrafts() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let allGamesBundle = try CRUD.readAllGames(for: dbConnection)
            
            let gameModels = (allGamesBundle[.games]! as? [SerializedGameModel])?.sorted { lhs, rhs in
                return lhs.getPosition() < rhs.getPosition()
            }
            
            XCTAssertNotNil(gameModels)
            
            let allGamesDrafts = gameModels!.map { gameModel in
                return gameModel.getMutableCopy()
            }

            XCTAssertEqual(allGamesDrafts.count, gameModels?.count)

            // MARK: Data copied correctly?
            zip(gameModels!, allGamesDrafts).forEach { gameFromDb, draft in
                XCTAssertEqual(gameFromDb.getName(), draft.getName())
                XCTAssertEqual(gameFromDb.getStudio(), draft.getStudio())
                XCTAssertEqual(gameFromDb.getPosition(), draft.getPosition())
            }
            
            let mixedPositions = (0..<13).shuffled()
            
            // MARK: Data updated correctly?
            zip(allGamesDrafts, mixedPositions).forEach { gameDraft, position in
                XCTAssertFalse(gameDraft.didPositionChange())

                gameDraft.withUpdatedPosition(position)
                                
                XCTAssertEqual(gameDraft.getPosition(), position)
                
                let previousOwner = gameModels!.first { model in
                    return model.getName() == gameDraft.getName()
                }
                
                XCTAssertNotNil(previousOwner)
                XCTAssertEqual(gameDraft.getPreviousPosition(), previousOwner!.getPosition())
                
                if (position != previousOwner!.getPosition()) {
                    XCTAssertTrue(gameDraft.didPositionChange())
                }
            }
            
            // MARK: Data validated correctly?
            try CRUD.updateGames(for: dbConnection) { draft in
                let matchingDraft = allGamesDrafts.first { model in
                    return model.getName() == draft.getName()
                }

                XCTAssertNotNil(matchingDraft)
                draft.withUpdatedPosition(matchingDraft!.getPosition())
            } validate: { updatedModels in
                let sortedModels = updatedModels.sorted {  lhs, rhs in
                    return lhs.getPosition() < rhs.getPosition()
                }
                
                XCTAssertEqual(sortedModels[0].getPosition(), 0)
                XCTAssertEqual(sortedModels.last!.getPosition(), 12)
                
                var isValid: Bool = true
                for i in 1..<13 {
                    isValid = isValid && sortedModels[i].getPosition() == sortedModels[i-1].getPosition() + 1
                    if (!isValid) {
                        break
                    }
                }
                
                return isValid
            }

            // MARK: Was the write successful?
            let updatedGames = (try CRUD.readAllGames(for: dbConnection)[.games]) as? [SerializedGameModel]
            XCTAssertNotNil(updatedGames)
            
            updatedGames!.forEach { updatedGameModel in
                let matchingDraft = allGamesDrafts.first { matchingDraft in
                    matchingDraft.getName() == updatedGameModel.getName()
                }
                
                XCTAssertNotNil(matchingDraft)
                
                XCTAssertEqual(updatedGameModel.getName(), matchingDraft?.getName())
                XCTAssertEqual(updatedGameModel.getStudio(), matchingDraft?.getStudio())
                XCTAssertEqual(updatedGameModel.getPosition(), matchingDraft?.getPosition())
            }
            

            return .rollback
        }
        
    }
    
    
    // MARK: - TEST TOOLS UPDATE
    public final func testToolPositionUpdates() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let toolsForShaolinEE = try CRUD.readToolsForTab(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "easter egg"
            )
            
            XCTAssertEqual(toolsForShaolinEE.count, 4)
            
            let drafts = toolsForShaolinEE.map { toolModel in
                return toolModel.getMutableCopy()
            }
            
            let randomPositions = (0..<4).shuffled()
            
            drafts.enumerated().forEach { i, draft in
                XCTAssertFalse(draft.didPositionChange())
                draft.withUpdatedPosition(randomPositions[i])
                
                if (randomPositions[i] != draft.getPreviousPosition()) {
                    XCTAssertTrue(draft.didPositionChange())
                }
            }
            
            try CRUD.updateToolsForTab(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "easter egg"
            ) { toolDraft in
                let matchingDraft = drafts.first { myDraft in
                    return myDraft.getName() == toolDraft.getName()
                }
                
                XCTAssertNotNil(matchingDraft)
                
                toolDraft.withUpdatedPosition(matchingDraft!.getPosition())
            } validate: { toolModels in
                let sortedModels = toolModels.sorted { lhs, rhs in
                    return lhs.getPosition() < rhs.getPosition()
                }
                
                XCTAssertEqual(sortedModels[0].getPosition(), 0)
                XCTAssertEqual(sortedModels.last!.getPosition(), 3)
                
                var valid = true
                for i in 1..<4 {
                    valid = valid && sortedModels[i].getPosition() == sortedModels[i-1].getPosition() + 1
                    
                    if (!valid) {
                        break
                    }
                }
                
                XCTAssertTrue(valid)
                return valid
            }

            
            return .rollback
        }
    }
    
}
