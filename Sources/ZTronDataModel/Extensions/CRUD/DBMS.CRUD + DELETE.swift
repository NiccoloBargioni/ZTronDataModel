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
    
    
    /// Use this method only if you know what you're doing. This deletes the specified image from the first-level images of the specified gallery.
    ///
    /// - Parameter shouldDecreasePositions: If set to `true`, the positions of the images after the specified one are decreased by one, otherwise they're left untouched.
    ///
    /// - Note: Deleting an image cascading deletes all the associated overlays and variants
    /// - Note: Deleting an image could or not cascading decreasee by one all the other first level images' positions in the same gallery whose position is greater than that of the deleted image. If the reference was dangling then the updated model already had the new positions corrected, otherwise specify that decreasing is needed.
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
        shouldDecreasePositions: Bool = false
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

        if shouldDecreasePositions {
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
    
    
    /// Use this method only if you know what you're doing. This deletes the hierarchy rooted in the specified image (excluded) of the specified image of the specified gallery.
    ///
    /// - Parameter shouldDecreasePositions: If set to `true`, the positions of the images after the specified one are decreased by one, otherwise they're left untouched.
    ///
    /// - Note: Deleting an image cascading deletes all the associated overlays and variants
    /// - Note: Deleting an image could or not cascading decreasee by one all the other first level images' positions in the same gallery whose position is greater than that of the deleted image. If the reference was dangling then the updated model already had the new positions corrected, otherwise specify that decreasing is needed.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func deleteImageVariant(
        for dbConnection: Connection,
        variant: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        func delete() throws -> Void {
            let visualMediaTable = DBMS.visualMedia
            
            try dbConnection.run(
                visualMediaTable.table.filter(
                    visualMediaTable.nameColumn == variant.lowercased() &&
                    visualMediaTable.foreignKeys.gameColumn == game.lowercased() &&
                    visualMediaTable.foreignKeys.mapColumn == map.lowercased() &&
                    visualMediaTable.foreignKeys.tabColumn == tab.lowercased() &&
                    visualMediaTable.foreignKeys.toolColumn == tool.lowercased() &&
                    visualMediaTable.foreignKeys.galleryColumn == gallery.lowercased()
                ).delete()
            )
        }
        
        if !shouldDecreasePositions {
            try delete()
        } else {
            guard let positionOfImageToDelete = try Self.readImagePosition(
                for: dbConnection,
                image: variant.lowercased(),
                game: game.lowercased(),
                map: map.lowercased(),
                tab: tab.lowercased(),
                tool: tool.lowercased(),
                gallery: gallery.lowercased()
            ) else {
                self.logger.warning("Attempted to read position of image to delete but no such image found.")
                return
            }
            
            if shouldDecreasePositions {
                if let masterImage = try Self.readImageMaster(
                    for: dbConnection,
                    slave: variant.lowercased(),
                    game: game.lowercased(),
                    map: map.lowercased(),
                    tab: tab.lowercased(),
                    tool: tool.lowercased(),
                    gallery: gallery.lowercased()
                ) {
                    try Self.decrementPositionsForVariantsOfMedia(
                        for: dbConnection,
                        parent: masterImage.getName(),
                        gallery: gallery.lowercased(),
                        tool: tool.lowercased(),
                        tab: tab.lowercased(),
                        map: map.lowercased(),
                        game: game.lowercased(),
                        threshold: positionOfImageToDelete
                    )
                } else {
                    Self.logger.error("Attempted to delete \(variant) as an image variant but no master was found. Attempting to delete as first-level image")
                }
            }
            
            try delete()
        }
    }
    
    
    /// Allows the user to iterate through all the serialized first-level images for the specified gallery. This method deletes from the database all the entries for which the `shouldRemove` parametrer returns true
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func batchDeleteFirstLevelImagesForGallery(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false,
        shouldRemove: @escaping (AnySerializedVisualMediaModel) -> Bool,
    ) throws -> Void {
        if let firstLevelImages = try Self.readFirstLevelMasterImagesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: gallery,
            options: [.medias]
        )[.medias] as? [any SerializedVisualMediaModel] {
            try firstLevelImages.forEach { firstLevelMedia in
                if shouldRemove(firstLevelMedia.erasedToAnySerializedVisualMediaModel()) {
                    try Self.deleteFirstLevelImageForGallery(
                        for: dbConnection,
                        image: firstLevelMedia.getName(),
                        gallery: gallery.lowercased(),
                        tool: tool.lowercased(),
                        tab: tab.lowercased(),
                        map: map.lowercased(),
                        game: game.lowercased(),
                        shouldDecreasePositions: shouldDecreasePositions
                    )
                }
            }
        } else {
            Self.logger.warning("Attempted to process first-level images of \(gallery) in an attempt to delete some, but such gallery has no associated image. Aborting.")
        }
    }
    
    
    /// Allows the user to iterate through all the serialized slave medias for the specified master. This method deletes from the database all the entries for which the `shouldRemove` parametrer returns true
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func batchDeleteFirstSlaveImagesForImage(
        for dbConnection: Connection,
        master: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false,
        shouldRemove: @escaping (AnySerializedVisualMediaModel) -> Bool,
    ) throws -> Void {
        let slaveImages = try Self.readAllVariants(
            for: dbConnection,
            master: master.lowercased(),
            game: game.lowercased(),
            map: map.lowercased(),
            tab: tab.lowercased(),
            tool: tool.lowercased(),
            gallery: gallery.lowercased()
        )
            
        try slaveImages.forEach { slaveMedia in
            if shouldRemove(slaveMedia.erasedToAnySerializedVisualMediaModel()) {
                try Self.deleteFirstLevelImageForGallery(
                    for: dbConnection,
                    image: slaveMedia.getName(),
                    gallery: gallery.lowercased(),
                    tool: tool.lowercased(),
                    tab: tab.lowercased(),
                    map: map.lowercased(),
                    game: game.lowercased(),
                    shouldDecreasePositions: shouldDecreasePositions
                )
            }
        }
    }
    
    
}
#endif
