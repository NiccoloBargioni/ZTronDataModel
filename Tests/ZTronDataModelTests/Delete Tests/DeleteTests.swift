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
    
    
    public final func testImageDelete() async throws {
        try DBMSMockProvider.transaction { connection in
            
            var randomImage: SerializedImageModel
            repeat {
                randomImage = try CRUD.randomImage(for: connection)
                let mastersCount = try CRUD.readImageMaster(
                    for: connection,
                    slave: randomImage.getName(),
                    game: randomImage.getGame(),
                    map: randomImage.getMap(),
                    tab: randomImage.getTab(),
                    tool: randomImage.getTool(),
                    gallery: randomImage.getGallery()
                )
                
                if mastersCount == nil {
                    break
                }
            } while(true);
            
            let gallery = DBMS.gallery
            
            let randomImageGalleryQuery = gallery.table.filter(
                gallery.nameColumn == randomImage.getGallery() &&
                gallery.foreignKeys.toolColumn == randomImage.getTool() &&
                gallery.foreignKeys.tabColumn == randomImage.getTab() &&
                gallery.foreignKeys.mapColumn == randomImage.getMap() &&
                gallery.foreignKeys.gameColumn == randomImage.getGame()
            )
            
            let path = "\(randomImage.getGame())/\(randomImage.getMap())/\(randomImage.getTab())/\(randomImage.getTool())/\(randomImage.getGallery())"

            
            guard let galleryEntry = try connection.pluck(randomImageGalleryQuery) else {
                fatalError("Unable to fetch \(path). Aborting")
            }
            
            let galleryModel = SerializedGalleryModel(galleryEntry)
            
            try CRUD.deleteFirstLevelImageForGallery(
                for: connection,
                image: randomImage.getName(),
                gallery: randomImage.getGallery(),
                tool: randomImage.getTool(),
                tab: randomImage.getTab(),
                map: randomImage.getMap(),
                game: randomImage.getGame(),
                shouldDecreasePositions: true
            )
            
            let imagesAfterDelete = try CRUD.readFirstLevelMasterImagesForGallery(
                for: connection,
                game: randomImage.getGame(),
                map: randomImage.getMap(),
                tab: randomImage.getTab(),
                tool: randomImage.getTool(),
                gallery: randomImage.getGallery(),
                options: [.medias]
            )
            
            guard let imageModelsAfterDelete = imagesAfterDelete[.medias] as? [SerializedImageModel] else {
                fatalError("Unable to fetch \(path) after delete. Aborting.")
            }
            
            // Maybe the gallery had just one image, if so, test successful by default.
            guard imageModelsAfterDelete.count > 0 else { return .rollback }
            
            let modelOfDeletedImage = imageModelsAfterDelete.first { modelAfterDelete in
                return modelAfterDelete.getName() == randomImage.getName() &&
                    modelAfterDelete.getGallery() == randomImage.getGallery() &&
                    modelAfterDelete.getTool() == randomImage.getTool() &&
                    modelAfterDelete.getTab() == randomImage.getTab() &&
                    modelAfterDelete.getMap() == randomImage.getMap() &&
                    modelAfterDelete.getGame() == randomImage.getGame()
            }
            
            XCTAssertNil(modelOfDeletedImage)
            
            let updatedPositions = imageModelsAfterDelete.map { image in
                return image.getPosition()
            }.sorted()
            
            XCTAssertEqual(updatedPositions[0], 0)
            XCTAssertEqual(updatedPositions[updatedPositions.count - 1], updatedPositions.count - 1)
            
            return .rollback
        }
    }
}
