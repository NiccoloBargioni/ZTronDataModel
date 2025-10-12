import Foundation
import SQLite3
import SQLite

#if DEBUG
public extension DBMS.CRUD {
    
    static func deleteStudio(for dbConnection: Connection, studio: String) throws {
        let studioModel = DomainModel.studio
        
        try dbConnection.run(
            studioModel.table.filter(studioModel.nameColumn == studio).delete()
        )
    }
    
    static func deleteGame(for dbConnection: Connection, game: String, studio: String) throws {
        let gameModel = DomainModel.game
        
        try dbConnection.run(
            gameModel.table.filter(gameModel.nameColumn == game && gameModel.foreignKeys.studioColumn == studio).delete()
        )
    }
    
    
    /*
     /// This method lists all the first-level medias for the specified
     ///
     ///
     /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
     /// - `PK(name, gallery, tool, tab, map, game)`
     /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
     static func updateVisualMediaPositions(
         for dbConnection: Connection,
         image: String,
         gallery: String,
         tool: String,
         tab: String,
         map: String,
         game: String,
         produce: @escaping (inout [any SerializedVisualMediaModelWritableDraft]) -> Void
     ) throws {
         if let firstLevelImagesForGallery = try Self.readFirstLevelMasterImagesForGallery(
             for: dbConnection,
             game: game,
             map: map,
             tab: tab,
             tool: tool,
             gallery: gallery,
             options: []
         )[.medias] as? [any SerializedVisualMediaModel] {
             guard firstLevelImagesForGallery.count > 0 else { return }
                 
             var imagesThatNeedUpdate = firstLevelImagesForGallery.map { model in
                 return model.getMutableCopy()
             }
             
             produce(&imagesThatNeedUpdate)
             
             let updatedModels = imagesThatNeedUpdate.map { draft in
                 return draft.getImmutableCopy()
             }
             
             let updatedModelsPositions: [Int] = updatedModels.map { model in
                 return model.getPosition()
             }.countingSorted()
             
             assert(updatedModelsPositions.count == firstLevelImagesForGallery.count)
             assert(updatedModelsPositions[0] == 0)
             assert(updatedModelsPositions[updatedModelsPositions.count - 1] ==  updatedModelsPositions.count - 1)
             
             try updatedModels.enumerated().forEach { i, model in
                 if model.getPosition() != firstLevelImagesForGallery[i].getPosition() {
                     try Self.updateVisualMediaPosition(
                         for: dbConnection,
                         position: model.getPosition(),
                         image: image.lowercased(),
                         gallery: gallery.lowercased(),
                         tool: tool.lowercased(),
                         tab: tab.lowercased(),
                         map: map.lowercased(),
                         game: game.lowercased()
                     )
                 }
             }
         } else {
             self.logger.error("Tried to cast `.medias` result for \(String(describing: Self.readFirstLevelMasterImagesForGallery)) to [\(String(describing: SerializedImageModel.self))] but cast unexpectedly fail.")
             fatalError()
         }
     }
     
     */
    
    /// Use this method only if you know what you're doing. This deletes the specified image from the first-level images of the specified gallery.
    ///
    /// - Note: Deleting an image cascading deletes all the associated overlays and variants
    /// - Note: Deleting an image cascading decreases by one all the other first level images' positions in the same gallery whose position is greater than that of the deleted image.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func deleteFirstLevelImageForGallery(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
    ) throws -> Void {
        guard let positionOfImageToDelete = try Self.readImagePosition(
            for: dbConnection,
            image: image,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: gallery
        ) else {
            self.logger.warning("Attempted to read position of image to delete but no such image found.")
            return
        }
        
        let visualMediaTable = DBMS.visualMedia
        
        let findImageQuery = visualMediaTable.table.filter(
            visualMediaTable.nameColumn == image.lowercased() &&
            visualMediaTable.foreignKeys.gameColumn == game.lowercased() &&
            visualMediaTable.foreignKeys.mapColumn == map.lowercased() &&
            visualMediaTable.foreignKeys.tabColumn == tab.lowercased() &&
            visualMediaTable.foreignKeys.toolColumn == tool.lowercased() &&
            visualMediaTable.foreignKeys.galleryColumn == gallery.lowercased()
        )

        
        try dbConnection.run(
            findImageQuery.delete()
        )

        try Self.decrementPositionsForFirstLevelImagesInGallery(
            for: dbConnection,
            gallery: gallery,
            tool: tool,
            tab: tab,
            map: map,
            game: game,
            threshold: positionOfImageToDelete
        )
    }
}
#endif
