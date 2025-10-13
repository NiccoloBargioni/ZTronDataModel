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
    
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateOutlineTab(
        for dbConnection: Connection,
        newTab: String,
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
                outline.foreignKeys.tabColumn <- newTab.lowercased()
            )
        )
    }
    
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateOutlinesForImage(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout SerializedOutlineModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedOutlineModel]) -> Bool
    ) throws -> Void {
        let outlineTable = DBMS.outline
        
        let findBoundingCirclesForImage = outlineTable.table.filter(
            outlineTable.foreignKeys.imageColumn == image &&
            outlineTable.foreignKeys.galleryColumn == gallery &&
            outlineTable.foreignKeys.toolColumn == tool &&
            outlineTable.foreignKeys.tabColumn == tab &&
            outlineTable.foreignKeys.mapColumn == map &&
            outlineTable.foreignKeys.gameColumn == game
        )
        
        var outlinesModelsDrafts = try dbConnection.prepare(findBoundingCirclesForImage).map { outlineRow in
            return SerializedOutlineModel(outlineRow).getMutableCopy()
        }
                
        
        for i in 0..<outlinesModelsDrafts.count {
            produce(&outlinesModelsDrafts[i])
        }
        
        guard validate(outlinesModelsDrafts.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        
        try outlinesModelsDrafts.forEach { outlineDraft in
            if outlineDraft.didOpacityChange() {
                try Self.updateOutlineOpacity(
                    for: dbConnection,
                    opacity: outlineDraft.getOpacity(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if outlineDraft.didColorHexChange() {
                try Self.updateOutlineColor(
                    for: dbConnection,
                    colorHex: outlineDraft.getColorHex(),
                    opacity: outlineDraft.getOpacity(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if outlineDraft.didIsActiveChange() {
                try Self.updateIsOutlineActive(
                    for: dbConnection,
                    isActive: outlineDraft.isActive(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if outlineDraft.didBoundingBoxChange() {
                let newBoundingBox = outlineDraft.getBoundingBox()
                
                try Self.updateOutlineBoundingBox(
                    for: dbConnection,
                    newOrigin: newBoundingBox.origin,
                    newSize: newBoundingBox.size,
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if outlineDraft.didResourceNameChange() {
                try Self.updateOutlineResourceName(
                    for: dbConnection,
                    newResourceName: outlineDraft.getResourceName(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
        }
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
    
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateBoundingCircleTab(
        for dbConnection: Connection,
        newTab: String,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let boundingCircle = DBMS.boundingCircle

        let outlineToUpdate = boundingCircle.table.filter(
            boundingCircle.foreignKeys.imageColumn == image &&
            boundingCircle.foreignKeys.galleryColumn == gallery.lowercased() &&
            boundingCircle.foreignKeys.toolColumn == tool.lowercased() &&
            boundingCircle.foreignKeys.tabColumn == tab.lowercased() &&
            boundingCircle.foreignKeys.mapColumn == map.lowercased() &&
            boundingCircle.foreignKeys.gameColumn == game.lowercased()
        )
        
        try dbConnection.run(
            outlineToUpdate.update(
                boundingCircle.foreignKeys.tabColumn <- newTab.lowercased()
            )
        )
    }
    
    
    /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCirclesForImage(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout SerializedBoundingCircleModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedBoundingCircleModel]) -> Bool
    ) throws -> Void {
        let boundingCircleTable = DBMS.boundingCircle
        
        let findBoundingCirclesForImage = boundingCircleTable.table.filter(
            boundingCircleTable.foreignKeys.imageColumn == image &&
            boundingCircleTable.foreignKeys.galleryColumn == gallery &&
            boundingCircleTable.foreignKeys.toolColumn == tool &&
            boundingCircleTable.foreignKeys.tabColumn == tab &&
            boundingCircleTable.foreignKeys.mapColumn == map &&
            boundingCircleTable.foreignKeys.gameColumn == game
        )
        
        var boundingCirclesModelsDrafts = try dbConnection.prepare(findBoundingCirclesForImage).map { boundingCircleRow in
            return SerializedBoundingCircleModel(boundingCircleRow).getMutableCopy()
        }
                
        
        for i in 0..<boundingCirclesModelsDrafts.count {
            produce(&boundingCirclesModelsDrafts[i])
        }
        
        guard validate(boundingCirclesModelsDrafts.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        try boundingCirclesModelsDrafts.forEach { boundingCircleDraft in
            if boundingCircleDraft.didOpacityChange() {
                try Self.updateBoundingCircleOpacity(
                    for: dbConnection,
                    opacity: boundingCircleDraft.getOpacity(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if boundingCircleDraft.didColorHexChange() {
                try Self.updateBoundingCircleColor(
                    for: dbConnection,
                    colorHex: boundingCircleDraft.getColorHex(),
                    opacity: boundingCircleDraft.getOpacity(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if boundingCircleDraft.didIsActiveChange() {
                try Self.updateIsBoundingCircleActive(
                    for: dbConnection,
                    isActive: boundingCircleDraft.isActive(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if boundingCircleDraft.didIdleDiameterChange() {
                try Self.updateBoundingCircleIdleDiameter(
                    for: dbConnection,
                    newDiameter: boundingCircleDraft.getIdleDiameter(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if boundingCircleDraft.didNormalizedCenterChange() {
                try Self.updateBoundingCircleCenter(
                    for: dbConnection,
                    newCenter: boundingCircleDraft.getNormalizedCenter(),
                    image: image,
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
        }
    }
    
    // MARK: - IMAGE VARIANT
    /// - `IMAGE_VARIANT(master, slave, variant, bottomBarIcon, boundingFrameOriginX, boundingFrameOriginY, boundingFrameWidth, boundingFrameHeight, gallery, tool, tab, map, game)`
    /// - `PK(slave, gallery, tool, tab, map, game)`
    /// - `FK(slave, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateImageVariantBottomBarIcon(
        for dbConnection: Connection,
        bottomBarIcon: String,
        master: String,
        slave: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let imageVariant = DBMS.imageVariant

        let variantToUpdate = imageVariant.table.filter(
            imageVariant.masterColumn == master &&
            imageVariant.slaveColumn == slave &&
            imageVariant.foreignKeys.galleryColumn == gallery.lowercased() &&
            imageVariant.foreignKeys.toolColumn == tool.lowercased() &&
            imageVariant.foreignKeys.tabColumn == tab.lowercased() &&
            imageVariant.foreignKeys.mapColumn == map.lowercased() &&
            imageVariant.foreignKeys.gameColumn == game.lowercased()
        ).update(
            imageVariant.bottomBarIconColumn <- bottomBarIcon.lowercased()
        )
        
        try dbConnection.run(variantToUpdate)
    }
    
    
    /// - `IMAGE_VARIANT(master, slave, variant, bottomBarIcon, boundingFrameOriginX, boundingFrameOriginY, boundingFrameWidth, boundingFrameHeight, gallery, tool, tab, map, game)`
    /// - `PK(slave, gallery, tool, tab, map, game)`
    /// - `FK(slave, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateImageVariantGoBackBottomBarIcon(
        for dbConnection: Connection,
        goBackBottomBarIcon: String?,
        master: String,
        slave: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let imageVariant = DBMS.imageVariant

        let variantToUpdate = imageVariant.table.filter(
            imageVariant.masterColumn == master &&
            imageVariant.slaveColumn == slave &&
            imageVariant.foreignKeys.galleryColumn == gallery.lowercased() &&
            imageVariant.foreignKeys.toolColumn == tool.lowercased() &&
            imageVariant.foreignKeys.tabColumn == tab.lowercased() &&
            imageVariant.foreignKeys.mapColumn == map.lowercased() &&
            imageVariant.foreignKeys.gameColumn == game.lowercased()
        ).update(
            imageVariant.goBackBottomBarIconColumn <- goBackBottomBarIcon?.lowercased()
        )
        
        try dbConnection.run(variantToUpdate)
    }
    
    /// - `IMAGE_VARIANT(master, slave, variant, bottomBarIcon, boundingFrameOriginX, boundingFrameOriginY, boundingFrameWidth, boundingFrameHeight, gallery, tool, tab, map, game)`
    /// - `PK(slave, gallery, tool, tab, map, game)`
    /// - `FK(slave, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateImageVariantBoundingFrame(
        for dbConnection: Connection,
        origin: CGPoint?,
        size: CGSize?,
        master: String,
        slave: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        assert(origin?.x ?? 0 >= 0 && origin?.x ?? 0 <= 1)
        assert(origin?.y ?? 0 >= 0 && origin?.y ?? 0 <= 1)
        assert(size?.width ?? 0 >= 0 && size?.width ?? 0 <= 1)
        assert(size?.height ?? 0 >= 0 && size?.height ?? 0 <= 1)
        assert(size != nil && origin != nil || size == nil && origin == nil)
        
        let imageVariant = DBMS.imageVariant

        let variantToUpdate = imageVariant.table.filter(
            imageVariant.masterColumn == master &&
            imageVariant.slaveColumn == slave &&
            imageVariant.foreignKeys.galleryColumn == gallery.lowercased() &&
            imageVariant.foreignKeys.toolColumn == tool.lowercased() &&
            imageVariant.foreignKeys.tabColumn == tab.lowercased() &&
            imageVariant.foreignKeys.mapColumn == map.lowercased() &&
            imageVariant.foreignKeys.gameColumn == game.lowercased()
        ).update(
            imageVariant.boundingFrameOriginXColumn <- origin?.x,
            imageVariant.boundingFrameOriginYColumn <- origin?.y,
            imageVariant.boundingFrameWidthColumn <- size?.width,
            imageVariant.boundingFrameHeightColumn <- size?.height,
        )
        
        try dbConnection.run(variantToUpdate)
    }
    
    
    static func updateVisualMediaMasterSlaveRelationshipsForMaster(
        for dbConnection: Connection,
        master: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout SerializedImageVariantMetadataModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedImageVariantMetadataModel]) -> Bool
    ) throws -> Void {
        let masterModel = try Self.readImageByID(
            for: dbConnection,
            image: master,
            gallery: gallery,
            tool: tool,
            tab: tab,
            map: map,
            game: game
        )
        
        guard let variantsForThisMaster = try Self.readVariantsMetadataForMediasSet(
            for: dbConnection,
            medias: [masterModel]
        ).first else {
            Self.logger.error("No variant found for this master. Aborting")
            return
        }
    
        guard var variantsDrafts = variantsForThisMaster?.getVariants().map ({ variantModel in
            return variantModel.getMutableCopy()
        }) else {
            Self.logger.error("Unable to make variants drafts for \(tool)/\(gallery)/\(master)")
            return
        }
        
        for i in 0..<variantsDrafts.count {
            produce(&variantsDrafts[i])
        }
        
        guard validate(variantsDrafts.map({ model in
            return model.getImmutableCopy()
        })) else {
            fatalError("Failed to validate variants drafts model")
        }
        
        try variantsDrafts.forEach { variantDraftModel in
            if variantDraftModel.didBottomBarIconUpdate() {
                try Self.updateImageVariantBottomBarIcon(
                    for: dbConnection,
                    bottomBarIcon: variantDraftModel.getBottomBarIcon(),
                    master: master,
                    slave: variantDraftModel.getSlave(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if variantDraftModel.didGoBackBottomBarIconUpdate() {
                try Self.updateImageVariantGoBackBottomBarIcon(
                    for: dbConnection,
                    goBackBottomBarIcon: variantDraftModel.getGoBackBottomBarIcon(),
                    master: master,
                    slave: variantDraftModel.getSlave(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if variantDraftModel.didOriginUpdate() || variantDraftModel.didSizeUpdate() {
                let updatedOrigin = variantDraftModel.getOrigin()
                let updatedSize = variantDraftModel.getSize()
                
                assert(updatedSize != nil && updatedOrigin != nil || updatedSize == nil && updatedOrigin == nil)
                
                try Self.updateImageVariantBoundingFrame(
                    for: dbConnection,
                    origin: updatedOrigin,
                    size: updatedSize,
                    master: master,
                    slave: variantDraftModel.getSlave(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
        }
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
    
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func updateVisualMediaTab(
        for dbConnection: Connection,
        newTab: String,
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
                visualMediaTable.descriptionColumn <- newTab.lowercased()
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
        assert(position >= 0)
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
    ///
    /// - Note: An assumption is made that `produce` doesn't alter the order of the input array
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
                media.foreignKeys.galleryColumn == gallery &&
                media.foreignKeys.toolColumn == tool &&
                media.foreignKeys.tabColumn == tab &&
                media.foreignKeys.mapColumn == map &&
                media.foreignKeys.gameColumn == game &&
                media.positionColumn > threshold)
            .update(media.positionColumn <- media.positionColumn - 1)
        )
    }
    
    /// For all the first-level variants of `image` whose position isß in [`threshold + 1`..< `gallery.firstLevelImages.count`], this method decreases their position by one.
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    internal static func decrementPositionsForVariantsOfMedia(
        for dbConnection: Connection,
        parent: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        threshold: Int = 0
    ) throws -> Void {
        let media = DBMS.visualMedia
        let imageVariant = DBMS.imageVariant
        
        let findSlavesQuery = imageVariant.table
            .select(imageVariant.slaveColumn)
            .filter(
                imageVariant.masterColumn == parent &&
                imageVariant.foreignKeys.gameColumn == game &&
                imageVariant.foreignKeys.mapColumn == map &&
                imageVariant.foreignKeys.tabColumn == tab &&
                imageVariant.foreignKeys.toolColumn == tool &&
                imageVariant.foreignKeys.galleryColumn == gallery
            )
        
        let slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[imageVariant.slaveColumn]
        }
        
        try dbConnection.run(
            media.table.filter(
                slaves.contains(media.nameColumn) &&
                media.foreignKeys.galleryColumn == gallery &&
                media.foreignKeys.toolColumn == tool &&
                media.foreignKeys.tabColumn == tab &&
                media.foreignKeys.mapColumn == map &&
                media.foreignKeys.gameColumn == game &&
                media.positionColumn > threshold)
            .update(media.positionColumn <- media.positionColumn - 1)
        )
    }
    
    /// For all the visual medias in the specified (`tool`, `map`, `game`), their `tab` is set to `targetTab`.
    ///
    /// - Note: Since `BOUNDING_CIRCLE`, `OUTLINES`, `LABEL` all reference `VISUAL_MEDIA.tab` as foreign keys and `VISUAL_MEDIA` specified `UPDATE CASCADE` policy, it's expected that all the overlays cascading update their `tab` column to match the new `targetTab`,
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    internal static func updateTabForAllVisualMediasInTool(
        for dbConnection: Connection,
        targetTab: String,
        gallery: String,
        tool: String,
        map: String,
        game: String,
    ) throws -> Void {
        let visualMedia = DBMS.visualMedia
        
        let tabUpdateQuery = visualMedia.table.filter(
            visualMedia.foreignKeys.galleryColumn == gallery &&
            visualMedia.foreignKeys.toolColumn == tool &&
            visualMedia.foreignKeys.mapColumn == map &&
            visualMedia.foreignKeys.gameColumn == game
        ).update(visualMedia.foreignKeys.tabColumn <- targetTab.lowercased())
        
        try dbConnection.run(tabUpdateQuery)
    }
    

    
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func updateFirstLevelVariantsOfImageForGallery(
        for dbConnection: Connection,
        master: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout any SerializedVisualMediaModelWritableDraft) -> Void,
        validate: @escaping ([any SerializedVisualMediaModel]) -> Bool
    ) throws -> Void {
        let masterVariantsForThisImage = (try Self.readAllVariants(
            for: dbConnection,
            master: master,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: gallery
        ))
        
        var draftForMasterMedia: [any SerializedVisualMediaModelWritableDraft] = masterVariantsForThisImage.map { media in
            return media.getMutableCopy()
        }
        
        for i in 0..<draftForMasterMedia.count {
            produce(&draftForMasterMedia[i])
        }
        
        guard validate(draftForMasterMedia.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        try draftForMasterMedia.forEach { mediaModelDraft in
            guard let neededUpdates = mediaModelDraft as? SerializedVisualMediaModelWritableDraftUpdateBearer else {
                fatalError("Cannot fetch requested updates info from visual media model.")
            }
            
            if neededUpdates.didPositionUpdate() {
                try Self.updateVisualMediaPosition(
                    for: dbConnection,
                    position: mediaModelDraft.getPosition(),
                    image: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if neededUpdates.didDescriptionUpdate() {
                try Self.updateVisualMediaCaption(
                    for: dbConnection,
                    caption: mediaModelDraft.getDescription(),
                    image: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if neededUpdates.didSearchLabelUpdate() {
                try Self.updateVisualMediaSearchLabel(
                    for: dbConnection,
                    searchLabel: mediaModelDraft.getSearchLabel(),
                    image: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if neededUpdates.didNameUpdate() {
                try Self.updateVisualMediaName(
                    for: dbConnection,
                    newName: mediaModelDraft.getName(),
                    currentName: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
        }
    }
    
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    static func updateMasterVisualMediasForGallery(
        for dbConnection: Connection,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout any SerializedVisualMediaModelWritableDraft) -> Void,
        validate: @escaping ([any SerializedVisualMediaModel]) -> Bool
    ) throws -> Void {
        guard let masterImagesForThisGallery = (try Self.readFirstLevelMasterImagesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: gallery,
            options: [.medias]
        )[.medias] as? [any SerializedVisualMediaModel]) else {
            fatalError("Unable to fetch visual media models for gallery \(tool)/\(gallery))")
        }
        
        var draftForMasterMedia: [any SerializedVisualMediaModelWritableDraft] = masterImagesForThisGallery.map { media in
            return media.getMutableCopy()
        }
        
        for i in 0..<draftForMasterMedia.count {
            produce(&draftForMasterMedia[i])
        }
        
        guard validate(draftForMasterMedia.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        try draftForMasterMedia.forEach { mediaModelDraft in
            guard let neededUpdates = mediaModelDraft as? SerializedVisualMediaModelWritableDraftUpdateBearer else {
                fatalError("Cannot fetch requested updates info from visual media model.")
            }
            
            if neededUpdates.didPositionUpdate() {
                try Self.updateVisualMediaPosition(
                    for: dbConnection,
                    position: mediaModelDraft.getPosition(),
                    image: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if neededUpdates.didDescriptionUpdate() {
                try Self.updateVisualMediaCaption(
                    for: dbConnection,
                    caption: mediaModelDraft.getDescription(),
                    image: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if neededUpdates.didSearchLabelUpdate() {
                try Self.updateVisualMediaSearchLabel(
                    for: dbConnection,
                    searchLabel: mediaModelDraft.getSearchLabel(),
                    image: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
            
            if neededUpdates.didNameUpdate() {
                try Self.updateVisualMediaName(
                    for: dbConnection,
                    newName: mediaModelDraft.getName(),
                    currentName: mediaModelDraft.getPreviousName(),
                    gallery: gallery,
                    tool: tool,
                    tab: tab,
                    map: map,
                    game: game
                )
            }
        }
    }
    
    // MARK: - GALLERIES
    /// For all the first-level galleries whose position is in [`threshold + 1`..< `firstLevelGalleries.count`], this method decreases their position by one.
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func decrementPositionsForFirstLevelGalleriesInTool(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
        threshold: Int = 0
    ) throws -> Void {
        let gallery = DBMS.gallery
        let slaves = DBMS.subgallery
        
        let findSlavesQuery = slaves.table
            .select(slaves.slaveColumn)
            .filter(
                slaves.foreignKeys.gameColumn == game &&
                slaves.foreignKeys.mapColumn == map &&
                slaves.foreignKeys.tabColumn == tab &&
                slaves.foreignKeys.toolColumn == tool
            )
        
        
        let slavesQuery = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[slaves.slaveColumn]
        }
        
        try dbConnection.run(
            gallery.table.filter(
                !slavesQuery.contains(gallery.nameColumn) &&
                gallery.foreignKeys.toolColumn == tool &&
                gallery.foreignKeys.tabColumn == tab &&
                gallery.foreignKeys.mapColumn == map &&
                gallery.foreignKeys.gameColumn == game &&
                gallery.positionColumn > threshold)
            .update(gallery.positionColumn <- gallery.positionColumn - 1)
        )
    }
    
    
    /// For all the first-level slaves of `master` gallery whose position is in [`threshold + 1`..< `gallery.firstLevelImages.count`], this method decreases their position by one.
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func decrementPositionsForImmediateSubgalleriesOfMaster(
        for dbConnection: Connection,
        parent: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        threshold: Int = 0
    ) throws -> Void {
        let gallery = DBMS.gallery
        let subgallery = DBMS.subgallery
        
        let findSlavesQuery = subgallery.table
            .select(subgallery.slaveColumn)
            .filter(
                subgallery.masterColumn == parent &&
                subgallery.foreignKeys.gameColumn == game &&
                subgallery.foreignKeys.mapColumn == map &&
                subgallery.foreignKeys.tabColumn == tab &&
                subgallery.foreignKeys.toolColumn == tool
            )
        
        let slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[subgallery.slaveColumn]
        }
        
        try dbConnection.run(
            gallery.table.filter(
                slaves.contains(gallery.nameColumn) &&
                gallery.foreignKeys.toolColumn == tool &&
                gallery.foreignKeys.tabColumn == tab &&
                gallery.foreignKeys.mapColumn == map &&
                gallery.foreignKeys.gameColumn == game &&
                gallery.positionColumn > threshold)
            .update(gallery.positionColumn <- gallery.positionColumn - 1)
        )
    }
    
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateGalleryName(
        for dbConnection: Connection,
        newGalleryName: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let galleryTable = DBMS.gallery
        
        let findGalleryQuery = galleryTable.table.filter(
                galleryTable.nameColumn == gallery &&
                galleryTable.foreignKeys.gameColumn == game &&
                galleryTable.foreignKeys.mapColumn == map &&
                galleryTable.foreignKeys.tabColumn == tab &&
                galleryTable.foreignKeys.toolColumn == tool
            ).update(galleryTable.nameColumn <- newGalleryName.lowercased())
                
        try dbConnection.run(findGalleryQuery)
    }
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateGalleryPosition(
        for dbConnection: Connection,
        position: Int,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        assert(position >= 0)
        let galleryTable = DBMS.gallery
        
        let findGalleryQuery = galleryTable.table.filter(
                galleryTable.nameColumn == gallery &&
                galleryTable.foreignKeys.gameColumn == game &&
                galleryTable.foreignKeys.mapColumn == map &&
                galleryTable.foreignKeys.tabColumn == tab &&
                galleryTable.foreignKeys.toolColumn == tool
            ).update(galleryTable.positionColumn <- position)
                
        try dbConnection.run(findGalleryQuery)
    }
    
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateGalleryAssetsImageName(
        for dbConnection: Connection,
        assetsImageName: String?,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let galleryTable = DBMS.gallery
        
        let updateGalleryQuery = galleryTable.table.filter(
                galleryTable.nameColumn == gallery &&
                galleryTable.foreignKeys.gameColumn == game &&
                galleryTable.foreignKeys.mapColumn == map &&
                galleryTable.foreignKeys.tabColumn == tab &&
                galleryTable.foreignKeys.toolColumn == tool
            ).update(galleryTable.assetsImageNameColumn <- assetsImageName)
                
        try dbConnection.run(updateGalleryQuery)
    }

    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal func updateGalleryTab(
        for dbConnection: Connection,
        newTab: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        let galleryTable = DBMS.gallery
        
        let updateGalleryQuery = galleryTable.table.filter(
                galleryTable.nameColumn == gallery &&
                galleryTable.foreignKeys.gameColumn == game &&
                galleryTable.foreignKeys.mapColumn == map &&
                galleryTable.foreignKeys.tabColumn == tab &&
                galleryTable.foreignKeys.toolColumn == tool
            ).update(galleryTable.foreignKeys.tabColumn <- newTab.lowercased())
                
        try dbConnection.run(updateGalleryQuery)
    }
    
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    /// - Note: An internal assumption is made that `produce` doesn't alter the order of the array.
    internal func batchUpdateFirstLevelGalleryPositions(
        for dbConnection: Connection,
        assetsImageName: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout [SerializedGalleryModel.WritableDraft]) -> Void
    ) throws -> Void {
        guard let galleries = try Self.readFirstLevelOfGalleriesForTool(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel] else {
            fatalError("Attempted to read the first level of master galleries in \(tool) but failed.")
        }
        
        if galleries.count > 0 {
            
            var drafts = galleries.map { galleryModel in
                return galleryModel.getMutableCopy()
            }
            
            produce(&drafts)
            
            let updatedModels = drafts.map { draftModel in
                return draftModel.getImmutableCopy()
            }
            
            let positions = updatedModels.map { updatedModel in
                return updatedModel.getPosition()
            }.countingSorted()
            
            assert(positions.count == galleries.count)
            assert(positions[0] == 0)
            assert(positions[positions.count - 1] == positions.count - 1)
            
            try updatedModels.enumerated().forEach { i, updatedGalleryModel in
                if updatedGalleryModel.getPosition() != galleries[i].getPosition() {
                    try Self.updateGalleryPosition(
                        for: dbConnection,
                        position: updatedGalleryModel.getPosition(),
                        gallery: updatedGalleryModel.getName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
            }
        }
    }
    
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    ///
    /// - Note: An internal assumption is made that `produce` doesn't alter the order of the array.
    internal func batchUpdatePositionsForImmediateSubgalleriesOfMaster(
        for dbConnection: Connection,
        assetsImageName: String,
        master: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout [SerializedGalleryModel.WritableDraft]) -> Void
    ) throws -> Void {
        guard let galleries = try Self.readFirstLevelOfSubgalleriesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: master,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel] else {
            fatalError("Attempted to read the first level of master galleries in \(tool) but failed.")
        }
        
        if galleries.count > 0 {
            var drafts = galleries.map { galleryModel in
                return galleryModel.getMutableCopy()
            }
            
            produce(&drafts)
            
            let updatedModels = drafts.map { draftModel in
                return draftModel.getImmutableCopy()
            }
            
            let positions = updatedModels.map { updatedModel in
                return updatedModel.getPosition()
            }.countingSorted()
            
            assert(positions.count == galleries.count)
            assert(positions[0] == 0)
            assert(positions[positions.count - 1] == positions.count - 1)
            
            try updatedModels.enumerated().forEach { i, updatedGalleryModel in
                if updatedGalleryModel.getPosition() != galleries[i].getPosition() {
                    try Self.updateGalleryPosition(
                        for: dbConnection,
                        position: updatedGalleryModel.getPosition(),
                        gallery: updatedGalleryModel.getName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
            }
        }
    }
    
    
    /// For all the galleries in the specified (`tool`, `map`, `game`), their `tab` is set to `targetTab`.
    ///
    /// - Note: Since `VISUAL_MEDIA` references `GALLERY.tab` as foreign keys and `GALLERY` specified `UPDATE CASCADE` policy, it's expected that all the `VISUAL_MEDIA` in the updated `GALLERY` cascading update their `tab` column to match the new `targetTab`, which in turn should `UPDATE CASCADE` all the overlays and variants' `tab` column.
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func updateTabForAllGalleriesInTool(
        for dbConnection: Connection,
        targetTab: String,
        tool: String,
        map: String,
        game: String,
    ) throws -> Void {
        let galleryTable = DBMS.gallery
        
        let tabUpdateQuery = galleryTable.table.filter(
            galleryTable.foreignKeys.toolColumn == tool &&
            galleryTable.foreignKeys.mapColumn == map &&
            galleryTable.foreignKeys.gameColumn == game
        ).update(galleryTable.foreignKeys.tabColumn <- targetTab.lowercased())
        
        try dbConnection.run(tabUpdateQuery)
    }
    
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateFirstLevelGalleriesForTab(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout SerializedGalleryModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedGalleryModel]) -> Bool
    ) throws -> Void {
        if let firstLevelGalleriesForThisTool = (try Self.readFirstLevelOfGalleriesForTool(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel]) {
            var galleryDraft = firstLevelGalleriesForThisTool.map { galleryModel in
                return galleryModel.getMutableCopy()
            }
            
            for i in 0..<firstLevelGalleriesForThisTool.count {
                produce(&galleryDraft[i])
            }

            guard validate(galleryDraft.map ({ draft in
                return draft.getImmutableCopy()
            })) else { fatalError("Unable to validate models. Aborting") }
            
            try galleryDraft.forEach { galleryDraftModel in
                if galleryDraftModel.didPositionUpdate() {
                    try Self.updateGalleryPosition(
                        for: dbConnection,
                        position: galleryDraftModel.getPosition(),
                        gallery: galleryDraftModel.getPreviousName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
                
                if galleryDraftModel.didAssetsImageNameUpdate() {
                    try Self.updateGalleryAssetsImageName(
                        for: dbConnection,
                        assetsImageName: galleryDraftModel.getAssetsImageName(),
                        gallery: galleryDraftModel.getPreviousName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
                
                if galleryDraftModel.didNameUpdate() {
                    try Self.updateGalleryName(
                        for: dbConnection,
                        newGalleryName: galleryDraftModel.getName(),
                        gallery: galleryDraftModel.getPreviousName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
            }
        } else {
            fatalError("Unable to read first level galleries for tool \(tool)")
        }
    }
    
    
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateFirstLevelSlaveGalleriesForMaster(
        for dbConnection: Connection,
        master: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout SerializedGalleryModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedGalleryModel]) -> Bool
    ) throws -> Void {
        if let firstLevelMasters = (try Self.readFirstLevelOfSubgalleriesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: master,
            options: [.galleries]
        )[.galleries] as? [SerializedGalleryModel]) {
            var galleryDraft = firstLevelMasters.map { galleryModel in
                return galleryModel.getMutableCopy()
            }
            
            for i in 0..<firstLevelMasters.count {
                produce(&galleryDraft[i])
            }

            guard validate(galleryDraft.map ({ draft in
                return draft.getImmutableCopy()
            })) else { fatalError("Unable to validate models. Aborting") }
            
            try galleryDraft.forEach { galleryDraftModel in
                if galleryDraftModel.didPositionUpdate() {
                    try Self.updateGalleryPosition(
                        for: dbConnection,
                        position: galleryDraftModel.getPosition(),
                        gallery: galleryDraftModel.getPreviousName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
                
                if galleryDraftModel.didAssetsImageNameUpdate() {
                    try Self.updateGalleryAssetsImageName(
                        for: dbConnection,
                        assetsImageName: galleryDraftModel.getAssetsImageName(),
                        gallery: galleryDraftModel.getPreviousName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
                
                if galleryDraftModel.didNameUpdate() {
                    try Self.updateGalleryName(
                        for: dbConnection,
                        newGalleryName: galleryDraftModel.getName(),
                        gallery: galleryDraftModel.getPreviousName(),
                        tool: tool,
                        tab: tab,
                        map: map,
                        game: game
                    )
                }
            }
        } else {
            fatalError("Unable to read first level galleries for tool \(tool)")
        }
    }
    
    
    // MARK: - TOOLS
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateToolName(
        for dbConnection: Connection,
        newToolName: String,
        tool: String,
        game: String,
        map: String,
        tab: String
    ) throws -> Void {
        let toolTable = DBMS.tool
        
        let updateToolQuery = toolTable.table.filter(
            toolTable.nameColumn == tool &&
            toolTable.foreignKeys.gameColumn == game &&
            toolTable.foreignKeys.mapColumn == map &&
            toolTable.foreignKeys.tabColumn == tab
        ).update(toolTable.nameColumn <- newToolName.lowercased())
                
        try dbConnection.run(updateToolQuery)
    }
    
    
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateToolPosition(
        for dbConnection: Connection,
        position: Int,
        tool: String,
        game: String,
        map: String,
        tab: String
    ) throws -> Void {
        assert(position >= 0)
        let toolTable = DBMS.tool
        
        let updateToolQuery = toolTable.table.filter(
            toolTable.nameColumn == tool &&
            toolTable.foreignKeys.gameColumn == game &&
            toolTable.foreignKeys.mapColumn == map &&
            toolTable.foreignKeys.tabColumn == tab
        ).update(toolTable.positionColumn <- position)
                
        try dbConnection.run(updateToolQuery)
    }
    
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateToolAssetsImageName(
        for dbConnection: Connection,
        newAssetsImageName: String,
        tool: String,
        game: String,
        map: String,
        tab: String
    ) throws -> Void {
        let toolTable = DBMS.tool
        
        let updateToolQuery = toolTable.table.filter(
            toolTable.nameColumn == tool &&
            toolTable.foreignKeys.gameColumn == game &&
            toolTable.foreignKeys.mapColumn == map &&
            toolTable.foreignKeys.tabColumn == tab
        ).update(toolTable.assetsImageNameColumn <- newAssetsImageName)
                
        try dbConnection.run(updateToolQuery)
    }
    
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    ///
    /// - Note: An internal assumption is made that `produce` doesn't alter the order of the array.
    internal func  batchUpdatePositionsForTools(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String,
        produce: @escaping (inout [SerializedToolModel.WritableDraft]) -> Void
    ) throws -> Void {
        let tools = try Self.readToolsForTab(for: dbConnection, game: game, map: map, tab: tab)
        
        var toolsDrafts = tools.map { tool in
            return tool.getMutableCopy()
        }
        
        if toolsDrafts.count > 0 {
            produce(&toolsDrafts)
            
            let updatedModels = toolsDrafts.map { draftModel in
                return draftModel.getImmutableCopy()
            }
            
            let positions = updatedModels.map { updatedModel in
                return updatedModel.getPosition()
            }.countingSorted()
            
            assert(positions.count == toolsDrafts.count)
            assert(positions[0] == 0)
            assert(positions[positions.count - 1] == positions.count - 1)
            
            try updatedModels.enumerated().forEach { i, updatedToolModel in
                
                if updatedToolModel.getPosition() != tools[i].getPosition() {
                    try Self.updateToolPosition(
                        for: dbConnection,
                        position: updatedToolModel.getPosition(),
                        tool: updatedToolModel.getName(),
                        game: game,
                        map: map,
                        tab: tab
                    )
                }
            }
        }
    }
    
    /// For all the tools in the specified tab whose position is [`threshold + 1`..< `tab.tools.count`], this method decreases their position by one.
    ///
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func decrementPositionsForToolsOfTab(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String,
        threshold: Int = 0
    ) throws -> Void {
        let tools = DBMS.tool
        
        try dbConnection.run(
            tools.table.filter(
                tools.foreignKeys.tabColumn == tab &&
                tools.foreignKeys.mapColumn == map &&
                tools.foreignKeys.gameColumn == game &&
                tools.positionColumn > threshold)
            .update(tools.positionColumn <- tools.positionColumn - 1)
        )
    }
    
    /// For all the tools in the specified tab whose position is [`threshold`..< `tab.tools.count`], this method increases their position by one.
    ///
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func incrementPositionsForToolsOfTab(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String,
        threshold: Int = 0
    ) throws -> Void {
        let tools = DBMS.tool
        
        try dbConnection.run(
            tools.table.filter(
                tools.foreignKeys.tabColumn == tab &&
                tools.foreignKeys.mapColumn == map &&
                tools.foreignKeys.gameColumn == game &&
                tools.positionColumn >= threshold)
            .update(tools.positionColumn <- tools.positionColumn + 1)
        )
    }
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    private static func updateTabForTool(
        for dbConnection: Connection,
        newTab: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
    ) throws -> Void {
        let tools = DBMS.tool
        
        try dbConnection.run(
            tools.table.filter(
                tools.foreignKeys.tabColumn == tab &&
                tools.foreignKeys.mapColumn == map &&
                tools.foreignKeys.gameColumn == game
            ).update(tools.foreignKeys.tabColumn <- tab.lowercased())
        )
    }
    
    
    /// TODO:
    /// - Since it's expensive, first check if the specified tool's tab is different from the target
    /// - Batch update the tab for `Tool`, `Gallery`, `Has_Subgallery`, `Image`, `Image_Has_Variant`, `Outline`, `Bounding_Box`
    /// - Update indices for tools of the former tab, if appropriate
    /// - Update indices for tools of the new tab, if appropriate
    /// - Update indices for the migrated tool.
    ///
    /// - Note: Expects that the new tab already exists on db.
    static func migrateToolToNewTab(
        for dbConnection: Connection,
        updatedPosition: Int? = nil,
        tool: String,
        map: String,
        game: String,
        sourceIndicesStrategy: TabMigrationSourcePositionStrategy = .preserveSourceIndices,
        targetIndicesStrategy: TabMigrationTargetPositionStrategy = .preserveTargetIndices,
        produce: @escaping (SerializedTabModel) -> OnTabConflictStrategy,
    ) throws -> Void {
        guard let previousTab = try? Self.readTabForTool(for: dbConnection, tool: tool, game: game, map: map) else {
            Self.logger.warning("Attempted to migrate tool to new tab but could not acquire info about previous tab.")
            return
        }
        
        #if DEBUG
        assert((try? Self.tabExists(for: dbConnection, tab: previousTab.getName(), map: map, game: game)) != nil)
        #endif
        
        guard (try? Self.toolExistsInDifferentTab(
            for: dbConnection,
            tool: tool,
            tab: previousTab.getName(),
            map: map,
            game: game)) ?? false else {
            Self.logger.warning("Attempted to migrate a tool to a new tab but that was not needed, skipping...")
            return
        }
        
        let toolModel = DBMS.tool
        
        let findAllTabsForThisToolQuery = toolModel.table.filter(
            toolModel.nameColumn == tool &&
            toolModel.foreignKeys.mapColumn == map &&
            toolModel.foreignKeys.gameColumn == game
        )
        
        let allTabsForThisTool = try dbConnection.prepare(findAllTabsForThisToolQuery).map { tabRow in
            return SerializedTabModel(tabRow)
        }
        
        guard allTabsForThisTool.count > 0 else { return }
        
        var targetTab: SerializedTabModel? = nil
        for tab in allTabsForThisTool {
            if produce(tab) == .keepCurrent {
                targetTab = tab
                break
            }
        }
        
        if let target = targetTab {
            guard target != previousTab else { return }
            
            if sourceIndicesStrategy == .updateSourceIndices {
                if let positionOfTool = try Self.readToolPosition(for: dbConnection, tool: tool, game: game, map: map, tab: previousTab.getName()) {
                    try Self.decrementPositionsForToolsOfTab(
                        for: dbConnection,
                        tab: previousTab.getName(),
                        map: map,
                        game: game,
                        threshold: positionOfTool
                    )
                } else {
                    fatalError("Could not read position of the tool in the source tab to decrement indices.")
                }
            }
            
            try Self.updateTabForTool(
                for: dbConnection,
                newTab: target.getName(),
                tool: tool,
                tab: previousTab.getName(),
                map: map,
                game: game
            )
            
            if targetIndicesStrategy == .updateTargetIndices {
                if let updatedPosition = updatedPosition {
                    try Self.updateToolPosition(
                        for: dbConnection,
                        position: updatedPosition,
                        tool: tool,
                        game: game,
                        map: map,
                        tab: target.getName()
                    )
                    
                    try Self.incrementPositionsForToolsOfTab(
                        for: dbConnection,
                        tab: target.getName(),
                        map: map,
                        game: game,
                        threshold: updatedPosition)
                } else {
                    if let positionOfTool = try Self.readToolPosition(for: dbConnection, tool: tool, game: game, map: map, tab: previousTab.getName()) {
                        try Self.updateToolPosition(
                            for: dbConnection,
                            position: positionOfTool,
                            tool: tool,
                            game: game,
                            map: map,
                            tab: target.getName()
                        )
                        
                        try Self.incrementPositionsForToolsOfTab(
                            for: dbConnection,
                            tab: target.getName(),
                            map: map,
                            game: game,
                            threshold: positionOfTool)
                    } else {
                        fatalError("Did not specify an updated position, and could not read position of the tool in the source tab to decrement indices.")
                    }
                }
            } else {
                if targetIndicesStrategy == .placeAtEnd {
                    if let numberOfTools = try? Self.countToolsForTab(
                        for: dbConnection,
                        game: game,
                        map: map,
                        tab: target.getName()
                    ) {
                        // NB: After moving tool to new tab, there are `numberOfTool + 1` tools in `targetTab`, spanning 0...numberOfTools. Therefore the new position will be numberOfTools
                        try Self.updateToolPosition(
                            for: dbConnection,
                            position: numberOfTools,
                            tool: tool,
                            game: game,
                            map: map,
                            tab: target.getName()
                        )
                    } else {
                        fatalError("Unable to count number of tools for tab \(target.getName())")
                    }
                }
            }
            /*To be fair, galleries for a tool reference `Tool.tab` and therefore updating such column cascade updates all of that's under that tool/**/
            try Self.updateTabForAllGalleriesInTool(
                for: dbConnection,
                targetTab: target.getName(),
                tool: tool,
                map: map,
                game: game
            )*/
        } else {
            fatalError("Unable to find target tab. 0/\(allTabsForThisTool.count) tabs were accepted.")
        }
    }
    
    
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateToolsForTab(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        produce: @escaping (inout SerializedToolModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedToolModel]) -> Bool
    ) throws -> Void {
        var toolsForThisTab = try Self.readToolsForTab(for: dbConnection, game: game, map: map, tab: tab).map { tabModel in
            return tabModel.getMutableCopy()
        }
        
        for i in 0..<toolsForThisTab.count {
            produce(&toolsForThisTab[i])
        }
        
        guard validate(toolsForThisTab.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        try toolsForThisTab.forEach { toolDraftModel in
            if toolDraftModel.didPositionChange() {
                try Self.updateToolPosition(
                    for: dbConnection,
                    position: toolDraftModel.getPosition(),
                    tool: toolDraftModel.getPreviousName(),
                    game: game,
                    map: map,
                    tab: toolDraftModel.getPreviousTab()
                )
            }
            
            if toolDraftModel.didAssetsImageNameChange() {
                try Self.updateToolAssetsImageName(
                    for: dbConnection,
                    newAssetsImageName: toolDraftModel.getAssetsImageName(),
                    tool: toolDraftModel.getPreviousName(),
                    game: game,
                    map: map,
                    tab: toolDraftModel.getPreviousTab()
                )
            }
            
            if toolDraftModel.didTabChange() {
                try Self.updateTabForTool(
                    for: dbConnection,
                    newTab: toolDraftModel.getTab(),
                    tool: toolDraftModel.getPreviousName(),
                    tab: toolDraftModel.getPreviousTab(),
                    map: map,
                    game: game
                )
            }
            
            if toolDraftModel.didNameChange() {
                try Self.updateTabName(
                    for: dbConnection,
                    newTabName: toolDraftModel.getName(),
                    game: game,
                    map: map,
                    tab: toolDraftModel.getTab()
                )
            }

        }
    }
    
    // MARK: - TAB
    /// For all the tools in the specified tab whose position is [`threshold + 1`..< `map.tabs.count`], this method decreases their position by one.
    ///
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func decrementPositionsForTabsInMap(
        for dbConnection: Connection,
        map: String,
        game: String,
        threshold: Int = 0
    ) throws -> Void {
        let tabs = DBMS.tab
        
        try dbConnection.run(
            tabs.table.filter(
                tabs.foreignKeys.mapColumn == map &&
                tabs.foreignKeys.gameColumn == game &&
                tabs.positionColumn > threshold)
            .update(tabs.positionColumn <- tabs.positionColumn - 1)
        )
    }
    
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateTabName(
        for dbConnection: Connection,
        newTabName: String,
        game: String,
        map: String,
        tab: String
    ) throws -> Void {
        let tabTable = DBMS.tab
        
        let updateTabQuery = tabTable.table.filter(
            tabTable.nameColumn == tab.lowercased() &&
            tabTable.foreignKeys.gameColumn == game &&
            tabTable.foreignKeys.mapColumn == map
        ).update(tabTable.nameColumn <- newTabName.lowercased())
                
        try dbConnection.run(updateTabQuery)
    }
    
    
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateTabPosition(
        for dbConnection: Connection,
        position: Int,
        game: String,
        map: String,
        tab: String
    ) throws -> Void {
        assert(position >= 0)
        let tabTable = DBMS.tab
        
        let updateTabQuery = tabTable.table.filter(
            tabTable.nameColumn == tab.lowercased() &&
            tabTable.foreignKeys.gameColumn == game &&
            tabTable.foreignKeys.mapColumn == map
        ).update(tabTable.positionColumn <- position)
                
        try dbConnection.run(updateTabQuery)
    }
    
    
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateTabsForMap(
        for dbConnection: Connection,
        game: String,
        map: String,
        produce: @escaping (inout SerializedTabModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedTabModel]) -> Bool
    ) throws -> Void {
        var tabsForThisMap = try Self.readTabsForMap(for: dbConnection, game: game, map: map).map { tabModel in
            return tabModel.getMutableCopy()
        }
        
        for i in 0..<tabsForThisMap.count {
            produce(&tabsForThisMap[i])
        }
        
        guard validate(tabsForThisMap.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        try tabsForThisMap.forEach { tabModelDraft in
            if tabModelDraft.didPositionChange() {
                try Self.updateTabPosition(
                    for: dbConnection,
                    position: tabModelDraft.getPosition(),
                    game: game,
                    map: map,
                    tab: tabModelDraft.getPreviousName()
                )
            }
            
            if tabModelDraft.didNameChange() {
                try Self.updateTabName(
                    for: dbConnection,
                    newTabName: tabModelDraft.getName(),
                    game: game,
                    map: map,
                    tab: tabModelDraft.getPreviousName()
                )
            }
        }
    }
    
    
    // MARK: - MAP
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateMapPosition(
        for dbConnection: Connection,
        newPosition: Int,
        game: String,
        map: String,
    ) throws -> Void {
        assert(newPosition >= 0)
        let mapTable = DBMS.map
        
        let updateTabQuery = mapTable.table.filter(
            mapTable.nameColumn == map &&
            mapTable.foreignKeys.gameColumn == game
        ).update(mapTable.positionColumn <- newPosition)
                
        try dbConnection.run(updateTabQuery)
    }
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateMapAssetsImageName(
        for dbConnection: Connection,
        newAssetsImageName: String,
        game: String,
        map: String,
    ) throws -> Void {
        let mapTable = DBMS.map
        
        let updateTabQuery = mapTable.table.filter(
            mapTable.nameColumn == map &&
            mapTable.foreignKeys.gameColumn == game
        ).update(mapTable.assetsImageNameColumn <- newAssetsImageName)
                
        try dbConnection.run(updateTabQuery)
    }
    
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateFirstLevelMapsForGame(
        for dbConnection: Connection,
        game: String,
        produce: @escaping (inout SerializedMapModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedMapModel]) -> Bool
    ) throws -> Void {
        guard var mapsForThisGame = (try Self.readAllMaps(
            for: dbConnection,
            game: game,
            limitToFirstLevelMasters: true
        )[.maps] as? [SerializedMapModel])?.map ({ tabModel in
            return tabModel.getMutableCopy()
        }) else {
            fatalError("Unable to load maps for game \(game). Aborting")
        }
        
        for i in 0..<mapsForThisGame.count {
            produce(&mapsForThisGame[i])
        }
        
        guard validate(mapsForThisGame.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        
        try mapsForThisGame.forEach { mapModelDraft in
            if mapModelDraft.didPositionChange() {
                try Self.updateMapPosition(
                    for: dbConnection,
                    newPosition: mapModelDraft.getPosition(),
                    game: game,
                    map: mapModelDraft.getName()
                )
            }
            
            if mapModelDraft.didAssetsImageNameChange() {
                try Self.updateMapAssetsImageName(
                    for: dbConnection,
                    newAssetsImageName: mapModelDraft.getAssetsImageName(),
                    game: game,
                    map: mapModelDraft.getName()
                )
            }
        }
    }
    
    
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateFirstLevelSubmapsOfMap(
        for dbConnection: Connection,
        master: String,
        game: String,
        produce: @escaping (inout SerializedMapModel.WritableDraft) -> Void,
        validate: @escaping ([SerializedMapModel]) -> Bool
    ) throws -> Void {
        guard var mapsForThisGame = (try Self.readAllSubmaps(
            for: dbConnection,
            master: master,
            game: game
        )[.maps] as? [SerializedMapModel])?.map ({ tabModel in
            return tabModel.getMutableCopy()
        }) else {
            fatalError("Unable to load maps for game \(game). Aborting")
        }
        
        for i in 0..<mapsForThisGame.count {
            produce(&mapsForThisGame[i])
        }
        
        guard validate(mapsForThisGame.map ({ draft in
            return draft.getImmutableCopy()
        })) else { fatalError("Unable to validate models. Aborting") }
        
        
        try mapsForThisGame.forEach { mapModelDraft in
            if mapModelDraft.didPositionChange() {
                try Self.updateMapPosition(
                    for: dbConnection,
                    newPosition: mapModelDraft.getPosition(),
                    game: game,
                    map: mapModelDraft.getName()
                )
            }
            
            if mapModelDraft.didAssetsImageNameChange() {
                try Self.updateMapAssetsImageName(
                    for: dbConnection,
                    newAssetsImageName: mapModelDraft.getAssetsImageName(),
                    game: game,
                    map: mapModelDraft.getName()
                )
            }
        }
    }
    
}


public enum TabMigrationSourcePositionStrategy: Hashable, Sendable {
    case preserveSourceIndices
    case updateSourceIndices
}

public enum TabMigrationTargetPositionStrategy: Hashable, Sendable {
    case preserveTargetIndices
    case updateTargetIndices
    case placeAtEnd
}
