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
        
        try DBMS.CRUD.insertIntoOutline(
            for: connection,
            resourceName: "outline",
            colorHex: "#FF11AA",
            isActive: true,
            opacity: 1.0,
            boundingBox: .init(origin: .zero, size: .init(width: 0.5, height: 0.5)),
            game: "infinite warfare",
            map: "spaceland",
            tab: "music",
            tool: "love the 80s",
            gallery: "master",
            image: "nunchaku step 1"
        )
        
        try DBMS.CRUD.insertIntoBoundingCircle(
            for: connection,
            colorHex: "#FF1100",
            isActive: true,
            opacity: 1.0,
            idleDiameter: nil,
            normalizedCenter: .init(x: 0.5, y: 0.5),
            game: "infinite warfare",
            map: "spaceland",
            tab: "music",
            tool: "love the 80s",
            gallery: "master",
            image: "nunchaku step 1"
        )
    }
}
