import Foundation
import SQLite3
import SQLite

public extension CRUD {
    
    @discardableResult static func deleteStudio(for dbConnection: Connection, studio: String) throws -> Int {
        let studioModel = DomainModel.studio
        
        try dbConnection.run(
            studioModel.table.filter(studioModel.nameColumn == studio).delete()
        )
        
        return dbConnection.changes
    }
    
    
    @discardableResult static func deleteGame(for dbConnection: Connection, game: String, studio: String) throws -> Int {
        let gameModel = DomainModel.game
        
        try dbConnection.run(
            gameModel.table.filter(gameModel.nameColumn == game && gameModel.foreignKeys.studioColumn == studio).delete()
        )
        
        return dbConnection.changes
    }
    
    // MARK: - OUTLINE
    @discardableResult static func deleteOutlineForImage(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Int {
        let outlineTable = DBMS.outline
        
        try dbConnection.run(
            outlineTable.table.filter(
                outlineTable.foreignKeys.imageColumn == image.lowercased() &&
                outlineTable.foreignKeys.gameColumn == game.lowercased() &&
                outlineTable.foreignKeys.mapColumn == map.lowercased() &&
                outlineTable.foreignKeys.tabColumn == tab.lowercased() &&
                outlineTable.foreignKeys.toolColumn == tool.lowercased() &&
                outlineTable.foreignKeys.galleryColumn == gallery.lowercased()
            ).delete()
        )
        
        return dbConnection.changes
    }
    
    
    // MARK: - BOUNDING CIRCLE
    @discardableResult static func deleteBoundingCircleForImage(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Int {
        let boundingCircleTable = DBMS.boundingCircle
        
        try dbConnection.run(
            boundingCircleTable.table.filter(
                boundingCircleTable.foreignKeys.imageColumn == image.lowercased() &&
                boundingCircleTable.foreignKeys.gameColumn == game.lowercased() &&
                boundingCircleTable.foreignKeys.mapColumn == map.lowercased() &&
                boundingCircleTable.foreignKeys.tabColumn == tab.lowercased() &&
                boundingCircleTable.foreignKeys.toolColumn == tool.lowercased() &&
                boundingCircleTable.foreignKeys.galleryColumn == gallery.lowercased()
            ).delete()
        )
        
        return dbConnection.changes
    }
    
    
    // MARK: - IMAGE
    /// Use this method only if you know what you're doing. This deletes the specified image from the first-level images of the specified gallery.
    ///
    /// - Parameter shouldDecreasePositions: If set to `true`, the positions of the images after the specified one are decreased by one, otherwise they're left untouched.
    ///
    /// - Note: Deleting an image cascading deletes all the associated overlays and variants
    /// - Note: Deleting an image could or not cascading decreasee by one all the other first level images' positions in the same gallery whose position is greater than that of the deleted image. If the reference was dangling then the updated model already had the new positions corrected, otherwise specify that decreasing is needed.
    /// - Returns: The number of deleted images, if `shouldDecreasePositions` is zero, the number of deleted images + the number of updated position otherwise.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    @discardableResult static func deleteFirstLevelImageForGallery(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
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
            return 0
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
        
        let deletedImagesCount = dbConnection.changes
        var numberOfDecrements: Int = 0
        
        if shouldDecreasePositions {
            numberOfDecrements = try Self.decrementPositionsForFirstLevelImagesInGallery(
                for: dbConnection,
                gallery: gallery,
                tool: tool,
                tab: tab,
                map: map,
                game: game,
                threshold: positionOfImageToDelete
            )
        }
        
        return deletedImagesCount + numberOfDecrements
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
    @discardableResult static func deleteImageVariant(
        for dbConnection: Connection,
        variant: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
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
            return dbConnection.changes
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
                return 0
            }
            
            var updatedPositionsCount: Int = 0
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
                    updatedPositionsCount += try Self.decrementPositionsForVariantsOfMedia(
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
            return dbConnection.changes + updatedPositionsCount
        }
    }
    
    
    /// Allows the user to iterate through all the serialized first-level images for the specified gallery. This method deletes from the database all the entries for which the `shouldRemove` parametrer returns true
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    @discardableResult static func batchDeleteFirstLevelImagesForGallery(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false,
        shouldRemove: @escaping (any SerializedVisualMediaModel) -> Bool
    ) throws -> Int {
        if let firstLevelImages = try Self.readFirstLevelMasterImagesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: gallery,
            options: [.medias]
        )[.medias] as? [any SerializedVisualMediaModel] {
            var deletedMediasCount: Int = 0
            
            try firstLevelImages.forEach { firstLevelMedia in
                if shouldRemove(firstLevelMedia) {
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
                    
                    deletedMediasCount += dbConnection.changes
                }
            }
            
            return deletedMediasCount
        } else {
            Self.logger.warning("Attempted to process first-level images of \(gallery) in an attempt to delete some, but such gallery has no associated image. Aborting.")
            return 0
        }
    }
    
    
    /// Allows the user to iterate through all the serialized slave medias for the specified master. This method deletes from the database all the entries for which the `shouldRemove` parametrer returns true
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    @discardableResult static func batchDeleteFirstSlaveImagesForImage(
        for dbConnection: Connection,
        master: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false,
        shouldRemove: @escaping (any SerializedVisualMediaModel) -> Bool
    ) throws -> Int {
        let slaveImages = try Self.readAllVariants(
            for: dbConnection,
            master: master.lowercased(),
            game: game.lowercased(),
            map: map.lowercased(),
            tab: tab.lowercased(),
            tool: tool.lowercased(),
            gallery: gallery.lowercased()
        )
            
        var deletedMediasCount: Int = 0
        
        try slaveImages.forEach { slaveMedia in
            if shouldRemove(slaveMedia) {
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
                
                deletedMediasCount += dbConnection.changes
            }
        }
        
        return deletedMediasCount
    }
    
    
    // MARK: - GALLERIES
    
    @discardableResult private static func deleteGallery(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Int {
        let galleryTable = DBMS.gallery
        
        let findGalleryQuery = galleryTable.table.filter(
            galleryTable.nameColumn == gallery.lowercased() &&
            galleryTable.foreignKeys.toolColumn == tool.lowercased() &&
            galleryTable.foreignKeys.tabColumn == tab.lowercased() &&
            galleryTable.foreignKeys.mapColumn == map.lowercased() &&
            galleryTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(findGalleryQuery.delete())
        
        return dbConnection.changes
    }

    
    /// Deletes the specified gallery from the tool, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult static func deleteFirstLevelGalleryForTool(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        guard !(try Self.galleryMasterExists(
            for: dbConnection,
            gallery: gallery,
            game: game,
            map: map,
            tab: tab,
            tool: tool
        )) else {
            try Self.deleteSubgalleryFromTool(
                for: dbConnection,
                gallery: gallery,
                tool: tool,
                tab: tab,
                map: map,
                game: game
            )
            return dbConnection.changes
        }
        
        let subtreeOfGallery = try Self.readSubgalleryTree(
            for: dbConnection,
            master: gallery.lowercased(),
            game: game.lowercased(),
            map: map.lowercased(),
            tab: tab.lowercased(),
            tool: tool.lowercased()
        )
        
        var decreasedPositionsCount: Int = 0
        
        if shouldDecreasePositions {
            if let posOfGalleryToDelete = try Self.readGalleryPosition(
                for: dbConnection,
                gallery: gallery,
                game: game,
                map: map,
                tab: tab,
                tool: tool
            ) {
                decreasedPositionsCount += try Self.decrementPositionsForFirstLevelGalleriesInTool(
                    for: dbConnection,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game,
                    threshold: posOfGalleryToDelete
                )
            } else {
                Self.logger.warning("Attempted to delete gallery named \(gallery) but no such gallery was found. Aborting")
                return 0
            }
        }
        
        var deletedSubgalleriesCount: Int = 0
        
        try subtreeOfGallery.forEach { galleryToDelete in
            try deleteGallery(
                for: dbConnection,
                gallery: gallery,
                tool: tool,
                tab: tab,
                map: map,
                game: game
            )
            
            deletedSubgalleriesCount += dbConnection.changes
        }
        
        return decreasedPositionsCount + deletedSubgalleriesCount
    }
    
    
    /// Deletes the specified gallery from the subtree rooted in its master, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - Parameter master: If the master is known you can provide it to save time complexity otherwise it is fetched from db.
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult static func deleteSubgalleryFromTool(
        for dbConnection: Connection,
        master: String? = nil,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        let fetchedMasterModel: SerializedGalleryModel? = (master == nil) ? try Self.readMasterForGallery(
            for: dbConnection,
            gallery: gallery,
            game: game,
            map: map,
            tab: tab,
            tool: tool
        ) : nil
        
        if master == nil && fetchedMasterModel == nil {
            try Self.deleteFirstLevelGalleryForTool(
                for: dbConnection,
                gallery: gallery,
                tool: tool,
                tab: tab,
                map: map,
                game: game,
                shouldDecreasePositions: shouldDecreasePositions
            )
            
            return dbConnection.changes
        } else {
            let subtreeOfGallery = try Self.readSubgalleryTree(
                for: dbConnection,
                master: gallery.lowercased(),
                game: game.lowercased(),
                map: map.lowercased(),
                tab: tab.lowercased(),
                tool: tool.lowercased()
            )
            
            var decreasedPositionsCount: Int = 0
            if shouldDecreasePositions {
                if let posOfGalleryToDelete = try Self.readGalleryPosition(
                    for: dbConnection,
                    gallery: gallery,
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool
                ) {
                    decreasedPositionsCount += try Self.decrementPositionsForImmediateSubgalleriesOfMaster(
                        for: dbConnection,
                        parent: master ?? fetchedMasterModel!.getName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game,
                        threshold: posOfGalleryToDelete
                    )
                } else {
                    Self.logger.warning("Attempted to delete gallery named \(gallery) but no such gallery was found. Aborting")
                }
            }
            
            var deletedSubgalleriesCount: Int = 0
            try subtreeOfGallery.forEach { galleryToDelete in
                try deleteGallery(
                    for: dbConnection,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
                
                deletedSubgalleriesCount += dbConnection.changes
            }
            
            return decreasedPositionsCount + deletedSubgalleriesCount
        }
    }
    
    
    /// Deletes the specified gallery from the subtree rooted in its master, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult static func batchDeleteFirstLevelGalleryForTool(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldRemove: (SerializedGalleryModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        if let firstLevelOfGalleries = try Self.readFirstLevelOfGalleriesForTool(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel] {
            var deletedGalleriesCount: Int = 0
            
            try firstLevelOfGalleries.forEach { gallery in
                if shouldRemove(gallery) {
                    try Self.deleteFirstLevelGalleryForTool(
                        for: dbConnection,
                        gallery: gallery.getName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game,
                        shouldDecreasePositions: shouldDecreasePositions
                    )
                    
                    deletedGalleriesCount += dbConnection.changes
                }
            }
            
            return deletedGalleriesCount
        } else {
            fatalError("Attempted to read first level of galleries for \(tool) but failed")
        }
    }
    
    
    
    /// Deletes the specified gallery from the subtree rooted in its master, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult static func batchDeleteSubgalleriesOfMasterForTool(
        for dbConnection: Connection,
        master: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldRemove: (SerializedGalleryModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        if let immediateSubgalleriesOfMaster = try Self.readFirstLevelOfSubgalleriesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: master,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel] {
            var deletedGalleriesCount: Int = 0
            
            try immediateSubgalleriesOfMaster.forEach { gallery in
                if shouldRemove(gallery) {
                    try Self.deleteSubgalleryFromTool(
                        for: dbConnection,
                        master: master,
                        gallery: gallery.getName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game,
                        shouldDecreasePositions: shouldDecreasePositions
                    )
                    
                    deletedGalleriesCount += dbConnection.changes
                }
            }
            
            return deletedGalleriesCount
        } else {
            fatalError("Attempted to read first level of subgalleries for \(master) in \(tool) but failed")
        }
    }
    
    // MARK: - TOOL
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult internal static func deleteTool(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        let toolTable = DBMS.tool
        
        func delete() throws {
            let findToolQuery = toolTable.table.filter(
                toolTable.nameColumn == tool.lowercased() &&
                toolTable.foreignKeys.tabColumn == tab.lowercased() &&
                toolTable.foreignKeys.mapColumn == map.lowercased() &&
                toolTable.foreignKeys.gameColumn == game.lowercased()
            )

            try dbConnection.run(findToolQuery.delete())
        }
        
        var decreasedToolsPositionsCount: Int = 0
        if shouldDecreasePositions {
            guard let position = try Self.readToolPosition(
                for: dbConnection,
                tool: tool,
                game: game,
                map: map,
                tab: tab
            ) else {
                fatalError("Attempted to delete a tool but could not find its position.")
            }
            
            decreasedToolsPositionsCount = try Self.decrementPositionsForToolsOfTab(
                for: dbConnection,
                tab: tab,
                map: map,
                game: game,
                threshold: position
            )
            
            try delete()
            return dbConnection.changes + decreasedToolsPositionsCount
        } else {
            try delete()
            return dbConnection.changes
        }
        
    }
    
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult static func batchDeleteToolsForTab(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String,
        shouldRemove: (SerializedToolModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        let toolsForThisTab = try Self.readToolsForTab(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab
        )
        
        var deletedToolsCount: Int = 0
        try toolsForThisTab.forEach { toolModel in
            if shouldRemove(toolModel) {
                try Self.deleteTool(
                    for: dbConnection,
                    tool: toolModel.getName(),
                    tab: tab,
                    map: map,
                    game: game,
                    shouldDecreasePositions: shouldDecreasePositions
                )
                
                deletedToolsCount += dbConnection.changes
            }
        }
        
        return deletedToolsCount
    }
    
    
    // MARK: - TABS
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult internal static func deleteTab(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        let tabTable = DBMS.tab
        
        func delete() throws {
            let findTabQuery = tabTable.table.filter(
                tabTable.nameColumn == tab.lowercased() &&
                tabTable.foreignKeys.mapColumn == map.lowercased() &&
                tabTable.foreignKeys.gameColumn == game.lowercased()
            )

            try dbConnection.run(findTabQuery.delete())
        }
        
        var decreasedPositionsCount: Int = 0
        if shouldDecreasePositions {
            guard let position = try Self.readTabPosition(
                for: dbConnection,
                game: game,
                map: map,
                tab: tab
            ) else {
                fatalError("Attempted to delete a tab but could not find its position.")
            }
            
            decreasedPositionsCount += try Self.decrementPositionsForTabsInMap(
                for: dbConnection,
                map: map,
                game: game,
                threshold: position
            )
            
            try delete()
            return dbConnection.changes + decreasedPositionsCount
        } else {
            try delete()
            return dbConnection.changes
        }
    }
    
    
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult static func batchDeleteTabsForMap(
        for dbConnection: Connection,
        map: String,
        game: String,
        shouldRemove: (SerializedTabModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        let tabsForThisMap = try Self.readTabsForMap(
            for: dbConnection,
            game: game,
            map: map
        )
        
        var changesCount: Int = 0
        
        try tabsForThisMap.forEach { tabModel in
            if shouldRemove(tabModel) {
                changesCount += try Self.deleteTab(
                    for: dbConnection,
                    tab: tabModel.getName(),
                    map: map,
                    game: game,
                    shouldDecreasePositions: shouldDecreasePositions
                )
            }
        }
        
        return changesCount
    }
    
    // MARK: - MAPS
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult internal static func deleteMap(
        for dbConnection: Connection,
        map: String,
        game: String
    ) throws -> Int {
        let mapTable = DBMS.map
        
        let subtreeOfMap = try Self.readSubmapsTree(
            for: dbConnection,
            master: map.lowercased(),
            game: game.lowercased()
        )

        var deletedMapsCount: Int = 0
        
        try subtreeOfMap.forEach { mapModel in
            let findMapQuery = mapTable.table.filter(
                mapTable.nameColumn == map.lowercased() &&
                mapTable.foreignKeys.gameColumn == game.lowercased()
            )

            try dbConnection.run(findMapQuery.delete())
            deletedMapsCount += dbConnection.changes
        }
        
        return deletedMapsCount
    }
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult internal static func deleteFirstLevelMap(
        for dbConnection: Connection,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
                
        if shouldDecreasePositions {
            guard let position = try Self.readMapPosition(
                for: dbConnection,
                game: game,
                map: map
            ) else {
                fatalError("Attempted to delete a map but could not find its position.")
            }
            
            let decrementsCount: Int = try Self.decrementPositionsForFirstLevelMapsInGame(
                for: dbConnection,
                game: game,
                threshold: position
            )
            
            try deleteMap(for: dbConnection, map: map, game: game)
            return dbConnection.changes + decrementsCount
        } else {
            try deleteMap(for: dbConnection, map: map, game: game)
            return dbConnection.changes
        }
    }
    
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult internal static func deleteSubmapOfMap(
        for dbConnection: Connection,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        guard let masterOfThisMap = try Self.readMapMaster(for: dbConnection, map: map, game: game) else {
            Self.logger.error("Attempted to delete immediate submap of map but couldn't find its master")
            return 0
        }
        
        if shouldDecreasePositions {
            guard let position = try Self.readMapPosition(
                for: dbConnection,
                game: game,
                map: map
            ) else {
                fatalError("Attempted to delete a submap but could not find its position.")
            }
            
            let numberOfDecrements: Int = try Self.decrementPositionsForSubmapsOfMaster(
                for: dbConnection,
                master: masterOfThisMap.getName(),
                game: game,
                threshold: position
            )
            
            try deleteMap(for: dbConnection, map: map, game: game)
            return dbConnection.changes + numberOfDecrements
        } else {
            try deleteMap(for: dbConnection, map: map, game: game)
            return dbConnection.changes
        }
    }
    
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    static func batchDeleteFirstLevelMapsForGame(
        for dbConnection: Connection,
        game: String,
        shouldRemove: (SerializedMapModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        guard let firstLevelMapsForThisGame = (try Self.readAllMaps(
            for: dbConnection,
            game: game,
            limitToFirstLevelMasters: true
        )[.maps] as? [SerializedMapModel]) else {
            fatalError("Attempted but failed to read list of first-level maps for game \(game)")
        }
        
        try firstLevelMapsForThisGame.forEach { mapModel in
            if shouldRemove(mapModel) {
                try Self.deleteFirstLevelMap(
                    for: dbConnection,
                    map: mapModel.getName(),
                    game: game,
                    shouldDecreasePositions: shouldDecreasePositions
                )
            }
        }
    }
    
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    static func batchDeleteFirstLevelSubmapsForMap(
        for dbConnection: Connection,
        master: String,
        game: String,
        shouldRemove: (SerializedMapModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        guard let firstLevelSlavesOfMap = (try Self.readAllSubmaps(
            for: dbConnection,
            master: master,
            game: game,
            limitToFirstLevelMasters: true
        )[.maps] as? [SerializedMapModel]) else {
            fatalError("Attempted but failed to read list of first-level submaps of \(master) for game \(game)")
        }
        
        try firstLevelSlavesOfMap.forEach { mapModel in
            if shouldRemove(mapModel) {
                try Self.deleteFirstLevelMap(
                    for: dbConnection,
                    map: mapModel.getName(),
                    game: game,
                    shouldDecreasePositions: shouldDecreasePositions
                )
            }
        }
    }
    
    // MARK: - GAME
    @discardableResult internal static func deleteGame(
        for dbConnection: Connection,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        let gameTable = DBMS.game
        
        func delete() throws {
            let findGameQuery = gameTable.table.filter(
                gameTable.nameColumn == game.lowercased()
            )

            try dbConnection.run(findGameQuery.delete())
        }
        
        if shouldDecreasePositions {
            guard let position = try Self.readGamePosition(
                for: dbConnection,
                game: game
            ) else {
                fatalError("Attempted to delete a game but could not find its position.")
            }
            
            let decreasedPositionsCount: Int = try Self.decrementPositionsForGames(for: dbConnection, threshold: position)
            
            try delete()
            return dbConnection.changes + decreasedPositionsCount
        } else {
            try delete()
            return dbConnection.changes
        }
    }
    
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    @discardableResult static func batchDeleteGames(
        for dbConnection: Connection,
        shouldRemove: (SerializedGameModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Int {
        guard let games = (try Self.readAllGames(
            for: dbConnection,
            options: [.games]
        )[.games] as? [SerializedGameModel]) else {
            fatalError("Attempted but failed to read list of all games")
        }
        
        var deletionsCount: Int = 0
        
        try games.forEach { gameModel in
            if shouldRemove(gameModel) {
                deletionsCount += try Self.deleteGame(
                    for: dbConnection,
                    game: gameModel.getName(),
                    shouldDecreasePositions: shouldDecreasePositions
                )
            }
        }
        
        return deletionsCount
    }
}
