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
    
    
    public final func testUpdateOutline() async throws {
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

            
            XCTAssertEqual(outlinesCount, 1)

            
            let randomRect: CGRect = .init(
                origin: CGPoint(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                ),
                size: CGSize(
                    width: CGFloat.random(in: 0...1),
                    height: CGFloat.random(in: 0...1)
                )
            )

            try CRUD.updateOutlineBoundingBox(
                for: dbConnection,
                newOrigin: randomRect.origin,
                newSize: randomRect.size,
                image: randomImage.getName(),
                gallery: randomGallery.getName(),
                tool: "iw.ss.side.quests.buildables.tool.name",
                tab: "side quests",
                map: "shaolin shuffle",
                game: "infinite warfare",
            )
            
            guard let outline = try CRUD.readOutlinesForMediasSet(
                for: dbConnection,
                medias: [randomImage]
            ).first else {
                fatalError("Failed to fetch updated outline")
            }

            XCTAssertEqual(
                outline!.getBoundingBox().origin.x,
                randomRect.origin.x,
                accuracy: 0.1
            )
            
            XCTAssertEqual(
                outline!.getBoundingBox().origin.y,
                randomRect.origin.y,
                accuracy: 0.1
            )
            
            XCTAssertEqual(
                outline!.getBoundingBox().size.width,
                randomRect.size.width,
                accuracy: 0.1
            )
            
            XCTAssertEqual(
                outline!.getBoundingBox().size.height,
                randomRect.size.height,
                accuracy: 0.1
            )
            
            return .rollback
        }
    }
}
