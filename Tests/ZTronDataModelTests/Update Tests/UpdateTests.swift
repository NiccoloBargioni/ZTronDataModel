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

    
    
    public final func testBatchUpdateOutlines() async throws {
        try DBMSMockProvider.transaction { connection in
            var randomImageWithOutline: SerializedImageModel
            var outlinesCount: Int
            
            repeat {
                randomImageWithOutline = try CRUD.randomImage(for: connection)
                outlinesCount = try CRUD.countOutlinesForImage(
                    for: connection,
                    game: randomImageWithOutline.getGame(),
                    map: randomImageWithOutline.getMap(),
                    tab: randomImageWithOutline.getTab(),
                    tool: randomImageWithOutline.getTool(),
                    gallery: randomImageWithOutline.getGallery(),
                    image: randomImageWithOutline.getName()
                )
                
                if outlinesCount > 0 {
                    break
                }
            } while(true)
            
            print("Performing test on \(randomImageWithOutline.getName())")
            
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

            var outlineName: String = ""
            
            try CRUD.updateOutlinesForImage(
                for: connection,
                image: randomImageWithOutline.getName(),
                gallery: randomImageWithOutline.getGallery(),
                tool: randomImageWithOutline.getTool(),
                tab: randomImageWithOutline.getTab(),
                map: randomImageWithOutline.getMap(),
                game: randomImageWithOutline.getGame()) { outlineDraft in
                    outlineName = outlineDraft.getResourceName()
                    
                    outlineDraft
                        .withResourceName(outlineDraft.getResourceName())
                        .withBoundingBox(randomRect)
                } validate: { _ in
                    return true
                }

            let outline = DBMS.outline
            let fetchOutlineQuery = outline.table.filter(
                outline.resourceNameColumn == outlineName
            )
            
            guard let outlineRow = try connection.pluck(fetchOutlineQuery) else {
                fatalError("Unable to fetch outline with name \(outlineName)")
            }
                
            let outlineModel = SerializedOutlineModel(outlineRow)
            
            XCTAssertEqual(outlineModel.getResourceName(), outlineName)
            XCTAssertEqual(outlineModel.getBoundingBox().origin.x, randomRect.origin.x)
            XCTAssertEqual(outlineModel.getBoundingBox().origin.y, randomRect.origin.y)
            XCTAssertEqual(outlineModel.getBoundingBox().size.width, randomRect.size.width)
            XCTAssertEqual(outlineModel.getBoundingBox().size.height, randomRect.size.height)
            XCTAssertEqual(outlineModel.getImage(), randomImageWithOutline.getName())
            XCTAssertEqual(outlineModel.getGallery(), randomImageWithOutline.getGallery())
            XCTAssertEqual(outlineModel.getTool(), randomImageWithOutline.getTool())
            XCTAssertEqual(outlineModel.getTab(), randomImageWithOutline.getTab())
            XCTAssertEqual(outlineModel.getMap(), randomImageWithOutline.getMap())
            XCTAssertEqual(outlineModel.getGame(), randomImageWithOutline.getGame())
            return .rollback
        }
    }
    
    
    public final func testBatchUpdateImages() async throws {
        try DBMSMockProvider.transaction { dbConnection in
            let randomGallery = try CRUD.randomGallery(for: dbConnection)
                
            let masters = try CRUD.readFirstLevelMasterImagesForGallery(
                for: dbConnection,
                game: randomGallery.getGame(),
                map: randomGallery.getMap(),
                tab: randomGallery.getTab(),
                tool: randomGallery.getTool(),
                gallery: randomGallery.getName(),
                options: [.medias]
            )
            
            let path = "\(randomGallery.getGame())/\(randomGallery.getMap())/\(randomGallery.getTab())/\(randomGallery.getTool())/\(randomGallery.getName())"

            
            guard let images = masters[.medias] as? [SerializedImageModel] else {
                fatalError("Unable to fetch images for \(path)")
            }
            
            guard images.count > 0 else {
                fatalError("\(path) has 0 master images associated with it. Aborting.")
            }
            
            let newPositions = Array(0..<images.count).shuffled()
            let updatedImages = zip(images, newPositions).map { image, newPosition in
                return image.getMutableCopy().withPosition(newPosition).getImmutableCopy()
            }
            
            try CRUD.updateMasterVisualMediasForGallery(
                for: dbConnection,
                gallery: randomGallery.getName(),
                tool: randomGallery.getTool(),
                tab: randomGallery.getTab(),
                map: randomGallery.getMap(),
                game: randomGallery.getGame()
            ) { imageDraft in
                    guard let matchingUpdatedDraft = updatedImages.first (where: { candidateModel in
                        return candidateModel.getName() == imageDraft.getName() &&
                             candidateModel.getGallery() == imageDraft.getGallery() &&
                             candidateModel.getTool() == imageDraft.getTool() &&
                             candidateModel.getTab() == imageDraft.getTab() &&
                             candidateModel.getGame() == imageDraft.getGame()
                    }) else {
                        let draftPath = "\(imageDraft.getGame())/\(imageDraft.getMap())/\(imageDraft.getTab())/\(imageDraft.getTool())/\(imageDraft.getGallery())/\(imageDraft.getName())"
                        fatalError("Unable to find matching draft for \(draftPath)")
                    }
                    
                    imageDraft
                        .withPosition(matchingUpdatedDraft.getPosition())
                } validate: { models in
                    return true
                }

            
            let mastersAfterUpdate = try CRUD.readFirstLevelMasterImagesForGallery(
                for: dbConnection,
                game: randomGallery.getGame(),
                map: randomGallery.getMap(),
                tab: randomGallery.getTab(),
                tool: randomGallery.getTool(),
                gallery: randomGallery.getName(),
                options: [.medias]
            )
            
            guard let imagesAfterUpdate = mastersAfterUpdate[.medias] as? [SerializedImageModel] else {
                fatalError("Unable to fetch images for \(path)")
            }

            let sortedUpdateDraft = updatedImages.sorted(by: { lhs, rhs in
                return lhs.getPosition() < rhs.getPosition()
            })
            
            zip(imagesAfterUpdate, sortedUpdateDraft).forEach { fetchedImage, updateDraft in
                XCTAssertEqual(fetchedImage.getName(), updateDraft.getName())
                XCTAssertEqual(fetchedImage.getGallery(), updateDraft.getGallery())
                XCTAssertEqual(fetchedImage.getTool(), updateDraft.getTool())
                XCTAssertEqual(fetchedImage.getTab(), updateDraft.getTab())
                XCTAssertEqual(fetchedImage.getMap(), updateDraft.getMap())
                XCTAssertEqual(fetchedImage.getGame(), updateDraft.getGame())
            }
            
            return .rollback
        }
    }
}
