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
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateOutlineColor(
        colorHex: String,
        opacity: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        // MARK: - VALIDATE INPUT PARAMETERS
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
        
        try DBMS.transaction { dbConnection in
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
            
            return .commit
        }
    }
    
    
    /// Updates the outline color hex and (optionally) opacity of the specified outline.
    ///
    /// - Parameter colorHex: The string representing an hex color, starting with `#`, with length 4 or 7 (including hashtag).
    /// - Parameter opacity: An optional number between `0-1` representing the opacity of the outline. If nil, the opacity remains unchanged.
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateOutlineOpacity(
        opacity: Double,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        // MARK: - VALIDATE INPUT PARAMETERS
        if opacity < 0 || opacity > 1 {
            throw UpdateError.validationError(reason: "Could not validate opacity \(opacity)")
        }
        
        
        try DBMS.transaction { dbConnection in
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
            
            return .commit
        }
    }
    
    
    static func updateIsOutlineActive(
        isActive: Bool,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        
        try DBMS.transaction { dbConnection in
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
            
            return .commit
        }
    }
    
    
    // MARK: - BOUNDING CIRCLE
    /// Updates the outline color hex and (optionally) opacity of the specified outline.
    ///
    /// - Parameter colorHex: The string representing an hex color, starting with `#`, with length 4 or 7 (including hashtag).
    /// - Parameter opacity: An optional number between `0-1` representing the opacity of the outline. If nil, the opacity remains unchanged.
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCircleColor(
        colorHex: String,
        opacity: Double?,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        // MARK: - VALIDATE INPUT PARAMETERS
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
        
        try DBMS.transaction { dbConnection in
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
            
            return .commit
        }
    }
    
    
    /// Updates the outline color hex and (optionally) opacity of the specified outline.
    ///
    /// - Parameter colorHex: The string representing an hex color, starting with `#`, with length 4 or 7 (including hashtag).
    /// - Parameter opacity: An optional number between `0-1` representing the opacity of the outline. If nil, the opacity remains unchanged.
    /// - `OUTLINE(resourceName, colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    static func updateBoundingCircleOpacity(
        opacity: Double,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        // MARK: - VALIDATE INPUT PARAMETERS
        if opacity < 0 || opacity > 1 {
            throw UpdateError.validationError(reason: "Could not validate opacity \(opacity)")
        }
        
        
        try DBMS.transaction { dbConnection in
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
            
            return .commit
        }
    }
    
    
    static func updateIsBoundingCircleActive(
        isActive: Bool,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Void {
        
        try DBMS.transaction { dbConnection in
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
            
            return .commit
        }
    }
}
