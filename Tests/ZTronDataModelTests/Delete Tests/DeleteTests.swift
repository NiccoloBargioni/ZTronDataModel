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
    
    
    public final func testOutlineAndCircleDelete() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            
            let galleriesForTool = try CRUD.readFirstLevelOfGalleriesForTool(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "side quests",
                tool: "iw.ss.side.quests.buildables.tool.name",
                options: [.galleries]
            )
            
            guard let theGalleries = galleriesForTool[.galleries] as? [SerializedGalleryModel] else {
                fatalError("Unable to retrieve galleries")
            }
            
            guard let randomGallery = theGalleries.randomElement() else {
                fatalError("Unable to make a random gallery for this tool")
            }
            
            let imagesForGallery = try CRUD.readFirstLevelMasterImagesForGallery(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "side quests",
                tool: "iw.ss.side.quests.buildables.tool.name",
                gallery: randomGallery.getName(),
                options: [.medias, .outlines, .boundingCircles]
            )
            
            guard let medias = imagesForGallery[.medias] as? [SerializedImageModel] else {
                fatalError("Maybe the gallery is empty?")
            }
            
            let indicesWithOutline = medias.enumerated().compactMap { i, image in
                if ((imagesForGallery[.outlines] as? [SerializedOutlineModel]) ?? []).count > 0 {
                    return i
                } else {
                    return nil
                }
            }
            
            guard let randomImageIndex = indicesWithOutline.randomElement() else {
                fatalError("Unable to draw an image with an outline for this gallery. Test results would be meaningless.")
            }
            
            let randomImage = medias[randomImageIndex]
            
            let outlinesCount = try CRUD.countOutlinesForImage(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "side quests",
                tool: "iw.ss.side.quests.buildables.tool.name",
                gallery: randomGallery.getName(),
                image: randomImage.getName()
            )
            
            print("Testing image \(randomGallery.getName())/\(randomImage.getName())")
            
            let boundingCirclesCount = try CRUD.countBoundingCirclesForImage(
                for: dbConnection,
                game: "infinite warfare",
                map: "shaolin shuffle",
                tab: "side quests",
                tool: "iw.ss.side.quests.buildables.tool.name",
                gallery: randomGallery.getName(),
                image: randomImage.getName()
            )
            
            XCTAssertEqual(outlinesCount, 1)
            XCTAssertEqual(boundingCirclesCount, 1)


            try CRUD.deleteOutlineForImage(
                for: dbConnection,
                image: randomImage.getName(),
                gallery: randomGallery.getName(),
                tool: "iw.ss.side.quests.buildables.tool.name",
                tab: "side quests",
                map: "shaolin shuffle",
                game: "infinite warfare",
            )
            
            
            let updatedOutlinesCount = try CRUD.countOutlinesForImage(
                for: dbConnection,
                game: "infinte warfare",
                map: "shaolin shuffle",
                tab: "side quests",
                tool: "iw.ss.side.quests.buildables.tool.name",
                gallery: randomGallery.getName(),
                image: randomImage.getName()
            )
            
            
            let updatedBoundingCirclesCount = try CRUD.countBoundingCirclesForImage(
                for: dbConnection,
                game: "infinte warfare",
                map: "shaolin shuffle",
                tab: "side quests",
                tool: "iw.ss.side.quests.buildables.tool.name",
                gallery: randomGallery.getName(),
                image: randomImage.getName()
            )
            
            
            XCTAssertEqual(updatedOutlinesCount, 0)
            XCTAssertEqual(updatedBoundingCirclesCount, 0)

            return .rollback
        }
    }
}
