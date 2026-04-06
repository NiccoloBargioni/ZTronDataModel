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
    
    
    public final func testBatchReadImages() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let randomGallery = try CRUD.randomGallery(for: dbConnection)
            
            let imagesForGallery = try CRUD.readFirstLevelMasterImagesForGallery(
                for: dbConnection,
                game: randomGallery.getGame(),
                map: randomGallery.getMap(),
                tab: randomGallery.getTab(),
                tool: randomGallery.getTool(),
                gallery: randomGallery.getName(),
                options: [.medias]
            )
            
            let path = "\(randomGallery.getGame())/\(randomGallery.getMap())/\(randomGallery.getTab())/\(randomGallery.getTool())/\(randomGallery.getName())"
            
            print("Running test with \(path)")
            
            guard let images = imagesForGallery[.medias] as? [SerializedImageModel] else {
                fatalError("Unable to fetch images for \(path)")
            }
            
            guard let firstImage = images.first else {
                fatalError("\(path) has 0 images associated with it. Aborting.")
            }
            
            images.forEach { image in
                XCTAssertEqual(image.getGallery(), firstImage.getGallery())
                XCTAssertEqual(image.getTool(), firstImage.getTool())
                XCTAssertEqual(image.getTab(), firstImage.getTab())
                XCTAssertEqual(image.getMap(), firstImage.getMap())
                XCTAssertEqual(image.getGame(), firstImage.getGame())
            }
            
            return .rollback
        }
    }
    
}
