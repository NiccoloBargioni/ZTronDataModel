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
    
    // MARK: - OUTLINE
    static func deleteOutlineForImage(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
    ) throws -> Void {
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
    }
    
    
    // MARK: - BOUNDING CIRCLE
    static func deleteBoundingCircleForImage(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
    ) throws -> Void {
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
    }
    
    
    // MARK: - IMAGE
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
        shouldRemove: @escaping (any SerializedVisualMediaModel) -> Bool,
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
        shouldRemove: @escaping (any SerializedVisualMediaModel) -> Bool,
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
            }
        }
    }
    
    
    // MARK: - GALLERIES
    
    private static func deleteGallery(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
    ) throws -> Void {
        let galleryTable = DBMS.gallery
        
        let findGalleryQuery = galleryTable.table.filter(
            galleryTable.nameColumn == gallery.lowercased() &&
            galleryTable.foreignKeys.toolColumn == tool.lowercased() &&
            galleryTable.foreignKeys.tabColumn == tab.lowercased() &&
            galleryTable.foreignKeys.mapColumn == map.lowercased() &&
            galleryTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(findGalleryQuery.delete())
    }

    
    /// Deletes the specified gallery from the tool, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func deleteFirstLevelGalleryForTool(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
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
            return
        }
        let subtreeOfGallery = try Self.readSubgalleryTree(
            for: dbConnection,
            master: gallery.lowercased(),
            game: game.lowercased(),
            map: map.lowercased(),
            tab: tab.lowercased(),
            tool: tool.lowercased()
        )
        
        if shouldDecreasePositions {
            if let posOfGalleryToDelete = try Self.readGalleryPosition(
                for: dbConnection,
                gallery: gallery,
                game: game,
                map: map,
                tab: tab,
                tool: tool
            ) {
                try Self.decrementPositionsForFirstLevelGalleriesInTool(
                    for: dbConnection,
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
        
        try subtreeOfGallery.forEach { galleryToDelete in
            try deleteGallery(
                for: dbConnection,
                gallery: gallery,
                tool: tool,
                tab: tab,
                map: map,
                game: game
            )
        }
    }
    
    /// Deletes the specified gallery from the subtree rooted in its master, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - Parameter master: If the master is known you can provide it to save time complexity otherwise it is fetched from db.
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func deleteSubgalleryFromTool(
        for dbConnection: Connection,
        master: String? = nil,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        
        
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
        } else {
            
            let subtreeOfGallery = try Self.readSubgalleryTree(
                for: dbConnection,
                master: gallery.lowercased(),
                game: game.lowercased(),
                map: map.lowercased(),
                tab: tab.lowercased(),
                tool: tool.lowercased()
            )
            
            if shouldDecreasePositions {
                if let posOfGalleryToDelete = try Self.readGalleryPosition(
                    for: dbConnection,
                    gallery: gallery,
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool
                ) {
                    try Self.decrementPositionsForImmediateSubgalleriesOfMaster(
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
            
            try subtreeOfGallery.forEach { galleryToDelete in
                try deleteGallery(
                    for: dbConnection,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
        }
    }
    
    
    /// Deletes the specified gallery from the subtree rooted in its master, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func batchDeleteFirstLevelGalleryForTool(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldRemove: (SerializedGalleryModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        
        if let firstLevelOfGalleries = try Self.readFirstLevelOfGalleriesForTool(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel] {
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
                }
            }
        } else {
            fatalError("Attempted to read first level of galleries for \(tool) but failed")
        }
    }
    
    
    
    /// Deletes the specified gallery from the subtree rooted in its master, along with all the subtree rooted in it. If `shouldDecreasePositions` is set to `true`, all the peer galleries whose position is greater than that of the deleted gallery
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func batchDeleteSubgalleriesOfMasterForTool(
        for dbConnection: Connection,
        master: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldRemove: (SerializedGalleryModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        if let immediateSubgalleriesOfMaster = try Self.readFirstLevelOfSubgalleriesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: master,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel] {
            
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
                }
            }
        } else {
            fatalError("Attempted to read first level of subgalleries for \(master) in \(tool) but failed")
        }
    }
    
    // MARK: - TOOL
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func deleteTool(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
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
            
            try Self.decrementPositionsForToolsOfTab(
                for: dbConnection,
                tab: tab,
                map: map,
                game: game,
                threshold: position
            )
            
            try delete()
        } else {
            try delete()
        }
        
    }
    
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func batchDeleteToolsForTab(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String,
        shouldRemove: (SerializedToolModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        let toolsForThisTab = try Self.readToolsForTab(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab
        )
        
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
            }
        }
    }
    
    
    // MARK: - TABS
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func deleteTab(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        let tabTable = DBMS.tab
        
        func delete() throws {
            let findToolQuery = tabTable.table.filter(
                tabTable.nameColumn == tab.lowercased() &&
                tabTable.foreignKeys.mapColumn == map.lowercased() &&
                tabTable.foreignKeys.gameColumn == game.lowercased()
            )

            try dbConnection.run(findToolQuery.delete())
        }
        
        if shouldDecreasePositions {
            guard let position = try Self.readTabPosition(
                for: dbConnection,
                game: game,
                map: map,
                tab: tab
            ) else {
                fatalError("Attempted to delete a tab but could not find its position.")
            }
            
            try Self.decrementPositionsForTabsInMap(
                for: dbConnection,
                map: map,
                game: game,
                threshold: position
            )
            
            try delete()
        } else {
            try delete()
        }
        
    }
    
    
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func batchDeleteTabsForMap(
        for dbConnection: Connection,
        map: String,
        game: String,
        shouldRemove: (SerializedTabModel) -> Bool,
        shouldDecreasePositions: Bool = false
    ) throws -> Void {
        let tabsForThisMap = try Self.readTabsForMap(
            for: dbConnection,
            game: game,
            map: map
        )
        
        try tabsForThisMap.forEach { tabModel in
            if shouldRemove(tabModel) {
                try Self.deleteTab(
                    for: dbConnection,
                    tab: tabModel.getName(),
                    map: map,
                    game: game,
                    shouldDecreasePositions: shouldDecreasePositions
                )
            }
        }
    }

    
}
#endif
