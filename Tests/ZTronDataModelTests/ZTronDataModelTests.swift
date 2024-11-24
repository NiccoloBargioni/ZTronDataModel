import XCTest
@testable import ZTronDataModel

final class ZTronDataModelTests: XCTestCase {
    func testReadImageByIDWithOptions() throws {
        let connection = try DBMS.openDB(caller: #function)
        
        try DBMS.make()
        
        try DBMS.CRUD.readImageByIDWithOptions(
            for: connection,
            image: "recreational.area.crate.binoculars",
            gallery: "binoculars",
            tool: "memory charms",
            tab: "side quests",
            map: "rave in the redwoods",
            game: "infinite warfare"
        )
    }
}
