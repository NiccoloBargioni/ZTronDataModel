import XCTest
import SQLite
import SQLite3
@testable import ZTronDataModel


final class UpdateTests: XCTestCase {
    
    
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
