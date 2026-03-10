import XCTest
import SQLite
import SQLite3
@testable import ZTronDataModel


final class ReadTests: XCTestCase {
    
    public final func testReadGameData() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let allGamesBundle = try CRUD.readAllGames(for: dbConnection)
            
            XCTAssertNotNil(allGamesBundle[.games])
            
            XCTAssertEqual(allGamesBundle[.games]!.count, 13)
            return .rollback
        }
    }
    
    
}
