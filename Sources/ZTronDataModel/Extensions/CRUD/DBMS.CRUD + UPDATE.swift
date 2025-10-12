import Foundation
import SQLite
import SQLite3

public enum UpdateError: Error {
    case validationError(reason: String)
}

public extension DBMS.CRUD {
    // MARK: - OUTLINE
    /// Updates the outline color hex and (optionally) opacity of the specified outline.
    ///
    /// - Parameter colorHex: The string representing an hex color, starting with `#`, with length 4 or 7 (including hashtag).
    /// - Parameter opacity: An optional number between `0-1` representing the opacity of the outline. If nil, the opacity remains unchanged.
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateOutlineColor(
        for dbConnection: Connection, 
        colorHex: String,
        opacity: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let matches = Self.hexValidatingRegex.matches(in: colorHex, range: NSRange(colorHex.startIndex..., in: colorHex))
        
        let stringResults = matches.map {
            String(colorHex[Range($0.range, in: colorHex)!])
        }

        if stringResults.count != 1 && stringResults.first!.count != colorHex.count {
            throw UpdateError.validationError(reason: "The provided color hex \(colorHex) couldn't be validated.")
        }
        
        if let opacity = opacity {
            if opacity < 0 || opacity > 1 {
                throw UpdateError.validationError(reason: "The provided opacity \(opacity) couldn't be validated.")
            }
        }
        
        let outlineTable = DBMS.outline
        
        let outlineToUpdate = outlineTable.table.filter(
            outlineTable.foreignKeys.imageColumn == image &&
            outlineTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            outlineTable.foreignKeys.toolColumn == tool.lowercased() &&
            outlineTable.foreignKeys.tabColumn == tab.lowercased() &&
            outlineTable.foreignKeys.mapColumn == map.lowercased() &&
            outlineTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        if let opacity = opacity {
            try dbConnection.run(
                outlineToUpdate.update(
                    outlineTable.colorHexColumn <- colorHex,
                    outlineTable.opacityColumn <- opacity
                )
            )
        } else {
            try dbConnection.run(
                outlineToUpdate.update(
                    outlineTable.colorHexColumn <- colorHex
                )
            )
        }
            
    }
    
    
    /// Updates the outline color hex and (optionally) opacity of the specified outline.
    ///
    /// - Parameter colorHex: The string representing an hex color, starting with `#`, with length 4 or 7 (including hashtag).
    /// - Parameter opacity: An optional number between `0-1` representing the opacity of the outline. If nil, the opacity remains unchanged.
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateOutlineOpacity(
        for dbConnection: Connection,
        opacity: Double,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        if opacity < 0 || opacity > 1 {
            throw UpdateError.validationError(reason: "Could not validate opacity \(opacity)")
        }
        
        
        let outlineTable = DBMS.outline
        
        let outlineToUpdate = outlineTable.table.filter(
            outlineTable.foreignKeys.imageColumn == image &&
            outlineTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            outlineTable.foreignKeys.toolColumn == tool.lowercased() &&
            outlineTable.foreignKeys.tabColumn == tab.lowercased() &&
            outlineTable.foreignKeys.mapColumn == map.lowercased() &&
            outlineTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            outlineToUpdate.update(
                outlineTable.opacityColumn <- opacity
            )
        )
    }
    
    
    /// Sets the outline to be enabled or disabled, according to the `isActive` parameter.
    ///
    /// - Parameter isActive: A boolean representing whether or not the outline should be enabled or disabled.
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateIsOutlineActive(
        for dbConnection: Connection,
        isActive: Bool,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        
        let outlineTable = DBMS.outline
        
        let outlineToUpdate = outlineTable.table.filter(
            outlineTable.foreignKeys.imageColumn == image &&
            outlineTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            outlineTable.foreignKeys.toolColumn == tool.lowercased() &&
            outlineTable.foreignKeys.tabColumn == tab.lowercased() &&
            outlineTable.foreignKeys.mapColumn == map.lowercased() &&
            outlineTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            outlineToUpdate.update(
                outlineTable.isActiveColumn <- isActive
            )
        )
    }
    
    
    /// Updates the bounding box of the outline to that hereby specified.
    ///
    /// - Parameter newOrigin: Specifies the new normalized origin. Both `x` and `y` fields are expected to be in [0,1].
    /// - Parameter newSize: Specifies the new normalized size of the outline. Both `width` and `height` fields are expected to be in [0,1].
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateOutlineBoundingBox(
        for dbConnection: Connection,
        newOrigin: CGPoint,
        newSize: CGSize,
        opacity: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        assert(newOrigin.x >= 0 && newOrigin.x <= 1)
        assert(newOrigin.y >= 0 && newOrigin.y <= 1)
        
        assert(newSize.width >= 0 && newSize.width <= 1)
        assert(newSize.height >= 0 && newSize.height <= 1)
        
        let outline = DBMS.outline
        
        let outlineToUpdate = outline.table.filter(
            outline.foreignKeys.imageColumn == image &&
            outline.foreignKeys.galleryColumn == gallery.lowercased() &&
            outline.foreignKeys.toolColumn == tool.lowercased() &&
            outline.foreignKeys.tabColumn == tab.lowercased() &&
            outline.foreignKeys.mapColumn == map.lowercased() &&
            outline.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            outlineToUpdate.update(
                outline.boundingBoxOriginXColumn <- newOrigin.x,
                outline.boundingBoxOriginYColumn <- newOrigin.y,
                outline.boundingBoxWidthColumn <- newSize.width,
                outline.boundingBoxOriginYColumn <- newSize.height,
            )
        )
    }
    
    
    /// Updates the outline resource name to match that specified by `newResourceName` parameter.
    ///
    /// - Parameter newResourceName: The new name for the outline, expected to be all lowercased. A lowercase version of this is written on db.
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateOutlineResourceName(
        for dbConnection: Connection,
        newResourceName: String,
        opacity: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let outline = DBMS.outline

        let outlineToUpdate = outline.table.filter(
            outline.foreignKeys.imageColumn == image &&
            outline.foreignKeys.galleryColumn == gallery.lowercased() &&
            outline.foreignKeys.toolColumn == tool.lowercased() &&
            outline.foreignKeys.tabColumn == tab.lowercased() &&
            outline.foreignKeys.mapColumn == map.lowercased() &&
            outline.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            outlineToUpdate.update(
                outline.resourceNameColumn <- newResourceName.lowercased()
            )
        )
    }
    
    
    /// If the specified outline is visible by default, this method makes it so that it's not visible by default, and the other way around.
    ///
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func toggleOutlineActive(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws {
        let sqlite3Connection = dbConnection.handle
        let outline = DBMS.outline
        
        try DBMS.performSQLStatement(
            for: sqlite3Connection,
            query: """
            UPDATE \(outline.tableName) 
            SET \(outline.isActiveColumn.template) = (
                    CASE WHEN \(outline.isActiveColumn.template) = 0 THEN 1
                    ELSE 0 END
            ) 
            WHERE \(outline.foreignKeys.imageColumn.template) = "\(image)" AND 
                  \(outline.foreignKeys.galleryColumn.template) = "\(gallery)" AND
                  \(outline.foreignKeys.toolColumn.template) = "\(tool)" AND
                  \(outline.foreignKeys.tabColumn.template) = "\(tab)" AND
                  \(outline.foreignKeys.mapColumn.template) = "\(map)" AND
                  \(outline.foreignKeys.gameColumn.template) = "\(game)"
            """
        )
    }
    
    // MARK: - BOUNDING CIRCLE
    /// Updates the outline color hex and (optionally) opacity of the specified outline.
    ///
    /// - Parameter colorHex: The string representing an hex color, starting with `#`, with length 4 or 7 (including hashtag).
    /// - Parameter opacity: An optional number between `0-1` representing the opacity of the outline. If nil, the opacity remains unchanged.
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCircleColor(
        for dbConnection: Connection,
        colorHex: String,
        opacity: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let matches = Self.hexValidatingRegex.matches(in: colorHex, range: NSRange(colorHex.startIndex..., in: colorHex))
        
        let stringResults = matches.map {
            String(colorHex[Range($0.range, in: colorHex)!])
        }

        if stringResults.count != 1 && stringResults.first!.count != colorHex.count {
            throw UpdateError.validationError(reason: "The provided color hex \(colorHex) couldn't be validated.")
        }
        
        if let opacity = opacity {
            if opacity < 0 || opacity > 1 {
                throw UpdateError.validationError(reason: "The provided opacity \(opacity) couldn't be validated.")
            }
        }
        
        let boundingCircle = DBMS.boundingCircle
        
        let boundingCircleToUpdate = boundingCircle.table.filter(
            boundingCircle.foreignKeys.imageColumn == image &&
            boundingCircle.foreignKeys.galleryColumn == gallery.lowercased() &&
            boundingCircle.foreignKeys.toolColumn == tool.lowercased() &&
            boundingCircle.foreignKeys.tabColumn == tab.lowercased() &&
            boundingCircle.foreignKeys.mapColumn == map.lowercased() &&
            boundingCircle.foreignKeys.gameColumn == game.lowercased()
        )
        
        if let opacity = opacity {
            try dbConnection.run(
                boundingCircleToUpdate.update(
                    boundingCircle.colorHexColumn <- colorHex,
                    boundingCircle.opacityColumn <- opacity
                )
            )
        } else {
            try dbConnection.run(
                boundingCircleToUpdate.update(
                    boundingCircle.colorHexColumn <- colorHex
                )
            )
        }
    }
    
    
    
    /// Updates the outline color hex and (optionally) opacity of the specified outline.
    ///
    /// - Parameter colorHex: The string representing an hex color, starting with `#`, with length 4 or 7 (including hashtag).
    /// - Parameter opacity: An optional number between `0-1` representing the opacity of the outline. If nil, the opacity remains unchanged.
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCircleOpacity(
        for dbConnection: Connection,
        opacity: Double,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        if opacity < 0 || opacity > 1 {
            throw UpdateError.validationError(reason: "Could not validate opacity \(opacity)")
        }
        
        
        let boundingCircleTable = DBMS.boundingCircle
        
        let boundingCircleToUpdate = boundingCircleTable.table.filter(
            boundingCircleTable.foreignKeys.imageColumn == image &&
            boundingCircleTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            boundingCircleTable.foreignKeys.toolColumn == tool.lowercased() &&
            boundingCircleTable.foreignKeys.tabColumn == tab.lowercased() &&
            boundingCircleTable.foreignKeys.mapColumn == map.lowercased() &&
            boundingCircleTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            boundingCircleToUpdate.update(
                boundingCircleTable.opacityColumn <- opacity
            )
        )
    }
    
    /// Updates the flag specifing whether or not the bounding circle should be visible by default.
    ///
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateIsBoundingCircleActive(
        for dbConnection: Connection,
        isActive: Bool,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        
        let boundingCircleTable = DBMS.boundingCircle
        
        let boundingCircleToUpdate = boundingCircleTable.table.filter(
            boundingCircleTable.foreignKeys.imageColumn == image &&
            boundingCircleTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            boundingCircleTable.foreignKeys.toolColumn == tool.lowercased() &&
            boundingCircleTable.foreignKeys.tabColumn == tab.lowercased() &&
            boundingCircleTable.foreignKeys.mapColumn == map.lowercased() &&
            boundingCircleTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            boundingCircleToUpdate.update(
                boundingCircleTable.isActiveColumn <- isActive
            )
        )
    }
    
    
    /// Updates the new normalised center coordinates to the specified `newCenter` parameter.
    ///
    /// - Parameter newCenter: Either a point whose `x` and `y` coordinates are in [0,1] or nil.
    ///
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCircleCenter(
        for dbConnection: Connection,
        newCenter: CGPoint?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        assert(newCenter?.x ?? 0 >= 0 && newCenter?.x ?? 0 <= 1)
        assert(newCenter?.y ?? 0 >= 0 && newCenter?.y ?? 0 <= 1)
        
        let boundingCircleTable = DBMS.boundingCircle
        
        let boundingCircleToUpdate = boundingCircleTable.table.filter(
            boundingCircleTable.foreignKeys.imageColumn == image &&
            boundingCircleTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            boundingCircleTable.foreignKeys.toolColumn == tool.lowercased() &&
            boundingCircleTable.foreignKeys.tabColumn == tab.lowercased() &&
            boundingCircleTable.foreignKeys.mapColumn == map.lowercased() &&
            boundingCircleTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            boundingCircleToUpdate.update(
                boundingCircleTable.normalizedCenterXColumn <- newCenter?.x,
                boundingCircleTable.normalizedCenterYColumn <- newCenter?.y
            )
        )
    }
    
    /// Updates the new initial diameter to the specified `newCenter` parameter.
    ///
    /// - Parameter newDiameter: Either a Double representing the normalized diameter of the bounding circle, i.e. in [0,1], or nil.
    ///
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCircleIdleDiameter(
        for dbConnection: Connection,
        newDiameter: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        assert(newDiameter ?? 0 >= 0 && newDiameter ?? 0 <= 1)
        
        let boundingCircleTable = DBMS.boundingCircle
        
        let boundingCircleToUpdate = boundingCircleTable.table.filter(
            boundingCircleTable.foreignKeys.imageColumn == image &&
            boundingCircleTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            boundingCircleTable.foreignKeys.toolColumn == tool.lowercased() &&
            boundingCircleTable.foreignKeys.tabColumn == tab.lowercased() &&
            boundingCircleTable.foreignKeys.mapColumn == map.lowercased() &&
            boundingCircleTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            boundingCircleToUpdate.update(
                boundingCircleTable.idleDiameterColumn <- newDiameter,
            )
        )
    }
    
    /// Updates the flag specifing whether or not the bounding circle should be visible by default.
    ///
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCircleCenter(
        for dbConnection: Connection,
        newCenter: CGPoint,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        assert(newCenter.x >= 0 && newCenter.x <= 1)
        assert(newCenter.y >= 0 && newCenter.y <= 1)
        
        let boundingCircleTable = DBMS.boundingCircle
        
        let boundingCircleToUpdate = boundingCircleTable.table.filter(
            boundingCircleTable.foreignKeys.imageColumn == image &&
            boundingCircleTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            boundingCircleTable.foreignKeys.toolColumn == tool.lowercased() &&
            boundingCircleTable.foreignKeys.tabColumn == tab.lowercased() &&
            boundingCircleTable.foreignKeys.mapColumn == map.lowercased() &&
            boundingCircleTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            boundingCircleToUpdate.update(
                boundingCircleTable.normalizedCenterXColumn <- newCenter.x,
                boundingCircleTable.normalizedCenterYColumn <- newCenter.y
            )
        )
    }
    
    
    
    /// If the specified bounding circle is visible by default, this method makes it so that it's not visible by default, and the other way around.
    ///
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func toggleBoundingCircleActive(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws {
        let sqlite3Connection = dbConnection.handle
        let boundingCircle = DBMS.boundingCircle
        
        try DBMS.performSQLStatement(
            for: sqlite3Connection,
            query: """
            UPDATE \(boundingCircle.tableName) 
            SET \(boundingCircle.isActiveColumn.template) = (
                    CASE WHEN \(boundingCircle.isActiveColumn.template) = 0 THEN 1
                    ELSE 0 END
            ) 
            WHERE \(boundingCircle.foreignKeys.imageColumn.template) = "\(image)" AND 
                  \(boundingCircle.foreignKeys.galleryColumn.template) = "\(gallery)" AND
                  \(boundingCircle.foreignKeys.toolColumn.template) = "\(tool)" AND
                  \(boundingCircle.foreignKeys.tabColumn.template) = "\(tab)" AND
                  \(boundingCircle.foreignKeys.mapColumn.template) = "\(map)" AND
                  \(boundingCircle.foreignKeys.gameColumn.template) = "\(game)"
            """
        )
    }
    
    // MARK: - VISUAL MEDIA (FORMER IMAGE)
    
    /// Updates the name of the resource associated with this image in the assets folder. Coincidentially, it updates the media identity on database, cascading
    /// to `OUTLINE`, `BOUNDING BOX`, `LABEL`.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func updateVisualMediaName(
        for dbConnection: Connection,
        newName: String,
        currentName: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws {
        let visualMediaTable = DBMS.visualMedia
                
        let imageToUpdate = visualMediaTable.table.filter(
            visualMediaTable.nameColumn == currentName.lowercased() &&
            visualMediaTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            visualMediaTable.foreignKeys.toolColumn == tool.lowercased() &&
            visualMediaTable.foreignKeys.tabColumn == tab.lowercased() &&
            visualMediaTable.foreignKeys.mapColumn == map.lowercased() &&
            visualMediaTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            imageToUpdate.update(
                visualMediaTable.nameColumn <- newName.lowercased()
            )
        )
    }
    
    
    /// Updates the LocalizedStringKey value associated with the caption of the specified visual media, to `caption.lowercased()`.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func updateVisualMediaCaption(
        for dbConnection: Connection,
        caption: String,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws {
        let visualMediaTable = DBMS.visualMedia
                
        let imageToUpdate = visualMediaTable.table.filter(
            visualMediaTable.nameColumn == image.lowercased() &&
            visualMediaTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            visualMediaTable.foreignKeys.toolColumn == tool.lowercased() &&
            visualMediaTable.foreignKeys.tabColumn == tab.lowercased() &&
            visualMediaTable.foreignKeys.mapColumn == map.lowercased() &&
            visualMediaTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            imageToUpdate.update(
                visualMediaTable.descriptionColumn <- caption.lowercased()
            )
        )
    }
    
    
    /// Updates the LocalizedStringKey value associated with the search label of the specified visual media, to `searchLabel.lowercased()`.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func updateVisualMediaSearchLabel(
        for dbConnection: Connection,
        searchLabel: String?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws {
        let visualMediaTable = DBMS.visualMedia
                
        let imageToUpdate = visualMediaTable.table.filter(
            visualMediaTable.nameColumn == image.lowercased() &&
            visualMediaTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            visualMediaTable.foreignKeys.toolColumn == tool.lowercased() &&
            visualMediaTable.foreignKeys.tabColumn == tab.lowercased() &&
            visualMediaTable.foreignKeys.mapColumn == map.lowercased() &&
            visualMediaTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            imageToUpdate.update(
                visualMediaTable.searchLabelColumn <- searchLabel?.lowercased()
            )
        )
    }
    
    
    /// Updates the position of the specified image to `position` value. This position is with respect to the other images in `gallery`.
    /// This method is unsafe to use! It might cause images in `gallery` not to span the whole `[0..<gallery.images.count]` range.
    ///
    /// It is heavily suggested to use the immer-style method instead.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func updateVisualMediaPosition(
        for dbConnection: Connection,
        position: Int,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws {
        let visualMediaTable = DBMS.visualMedia
                
        let imageToUpdate = visualMediaTable.table.filter(
            visualMediaTable.nameColumn == image.lowercased() &&
            visualMediaTable.foreignKeys.galleryColumn == gallery.lowercased() &&
            visualMediaTable.foreignKeys.toolColumn == tool.lowercased() &&
            visualMediaTable.foreignKeys.tabColumn == tab.lowercased() &&
            visualMediaTable.foreignKeys.mapColumn == map.lowercased() &&
            visualMediaTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            imageToUpdate.update(
                visualMediaTable.positionColumn <- position
            )
        )
    }
    
    
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
    
    
    /// For all the first-level images whose position is in [`threshold + 1`..< `gallery.firstLevelImages.count`], this method decreases their position by one.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    internal static func decrementPositionsForFirstLevelImagesInGallery(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        threshold: Int = 0
    ) throws -> Void {
        let media = DBMS.visualMedia
        let imageVariant = DBMS.imageVariant
        
        var findSlavesQuery = imageVariant.table
            .select(imageVariant.slaveColumn)
            .filter(
                imageVariant.foreignKeys.gameColumn == game &&
                imageVariant.foreignKeys.mapColumn == map &&
                imageVariant.foreignKeys.tabColumn == tab &&
                imageVariant.foreignKeys.toolColumn == tool
            )
        
        findSlavesQuery = findSlavesQuery.filter(imageVariant.foreignKeys.galleryColumn == gallery)
        
        let slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[imageVariant.slaveColumn]
        }
        
        try dbConnection.run(
            media.table.filter(
                !slaves.contains(media.nameColumn) &&
                media.foreignKeys.gameColumn == gallery &&
                media.foreignKeys.toolColumn == tool &&
                media.foreignKeys.tabColumn == tab &&
                media.foreignKeys.mapColumn == map &&
                media.foreignKeys.gameColumn == game &&
                media.positionColumn > threshold)
            .update(media.positionColumn <- media.positionColumn - 1)
        )
    }
    
    
}
