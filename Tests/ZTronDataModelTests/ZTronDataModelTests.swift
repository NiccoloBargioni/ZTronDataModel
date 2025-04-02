import XCTest
@testable import ZTronDataModel

final class ZTronDataModelTests: XCTestCase {
    func testTriggers() throws {
        let connection = try DBMS.openDB(caller: #function)
        
        try DBMS.make()
        try DBMS.mockInit(or: .ignore)
        
        try DBMS.CRUD.insertIntoGallery(
            for: connection,
            name: "master",
            position: 0,
            assetsImageName: "placeholder",
            game: "infinite warfare",
            map: "spaceland",
            tab: "music",
            tool: "love the 80s"
        )
        
        try DBMS.CRUD.insertIntoVisualMedia(
            or: .rollback,
            for: connection,
            type: .image,
            format: nil,
            name: "nunchaku step 1",
            description: "yadayadayads",
            position: 0,
            searchLabel: nil,
            game: "infinite warfare",
            map: "spaceland",
            tab: "music",
            tool: "love the 80s",
            gallery: "master"
        )
    }
}
