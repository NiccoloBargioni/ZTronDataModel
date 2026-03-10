import XCTest
import SQLite
import SQLite3
@testable import ZTronDataModel


final class DeleteTests: XCTestCase {
    
    
    // MARK: - TEST TOOLS DELETE
    public final func testToolsDelete() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let previousSSEEToolsCount = try CRUD.countToolsForTab(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "easter egg"
            )
            
            
            try CRUD.batchDeleteToolsForTab(
                for: dbConnection,
                tab: "easter egg",
                map: "shaolin shuffle",
                game: "infinite warfare",
                shouldRemove: { toolModel in
                    return toolModel.getName() == "iw.ss.easter.egg.rooftop.cypher.tool.name" /*Position = 3*/
                },
                shouldDecreasePositions: false
            )
            
            let shaolinEEToolsAfterDelete = try CRUD.readToolsForTab(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "easter egg"
            )
            
            XCTAssertEqual(shaolinEEToolsAfterDelete.count, previousSSEEToolsCount - 1)
            
            
            let rooftopCypherTool = shaolinEEToolsAfterDelete.first { toolModel in
                return toolModel.getName() == "iw.ss.easter.egg.rooftop.cypher.tool.name"
            }
            
            XCTAssertNil(rooftopCypherTool)
            
            let thirdTool = shaolinEEToolsAfterDelete.first { toolModel in
                return toolModel.getPosition() == 3
            }
            
            XCTAssertNil(thirdTool)
            
            return .rollback
        }
    }
    
    public final func testToolsDeleteWithDecrement() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let previousSSEEToolsCount = try CRUD.countToolsForTab(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "easter egg"
            )
            
            try CRUD.batchDeleteToolsForTab(
                for: dbConnection,
                tab: "easter egg",
                map: "shaolin shuffle",
                game: "infinite warfare",
                shouldRemove: { toolModel in
                    return toolModel.getName() == "iw.ss.easter.egg.rooftop.cypher.tool.name" /*Position = 3*/
                },
                shouldDecreasePositions: true
            )
            
            let shaolinEEToolsAfterDelete = try CRUD.readToolsForTab(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "easter egg"
            )
            
            XCTAssertEqual(shaolinEEToolsAfterDelete.count, previousSSEEToolsCount - 1)
            
            shaolinEEToolsAfterDelete.enumerated().forEach { i, tool in
                XCTAssertEqual(i, tool.getPosition())
            }
            
            return .rollback
        }
    }
}
