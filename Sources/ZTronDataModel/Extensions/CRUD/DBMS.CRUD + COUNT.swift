import Foundation
import SQLite3
import SQLite

extension DBMS.CRUD {
    
    // MARK: STUDIOS
    public static func countStudios(for dbConnection: Connection) throws -> Int {
        let studios = DBMS.studio
        
        let countStudiosStatement = studios.table.count
        return try dbConnection.scalar(countStudiosStatement)
    }
    
    
    // MARK: GAMES
    public static func countGamesForStudio(for dbConnection: Connection, studio: String) throws -> Int {
        let studios = DBMS.studio
        let countGamesForStudioQuery = studios.table.where(studios.nameColumn == studio).count
        
        return try dbConnection.scalar(countGamesForStudioQuery)
    }

    
    // MARK: MAPS
    public static func countMapsForGame(for dbConnection: Connection, game: String) throws -> Int {
        let map = DBMS.map
        let countMapsForGameQuery = map.table.where(map.foreignKeys.gameColumn == game).count
        
        return try dbConnection.scalar(countMapsForGameQuery)
    }
    
    // MARK: TABS
    public static func countTabsForMap(
        for dbConnection: Connection,
        game: String,
        map: String
    ) throws -> Int {
        let tab = DBMS.tab
        let countTabsForMapQuery = tab.table.where(
            tab.foreignKeys.gameColumn == game &&
            tab.foreignKeys.mapColumn == map
        ).count
        
        return try dbConnection.scalar(countTabsForMapQuery)
    }
    
    // MARK: TOOLS
    public static func countToolsForTab(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String
    ) throws -> Int {
        let tool = DBMS.tool
        let countToolsForTabQuery = tool.table.where(
            tool.foreignKeys.gameColumn == game &&
            tool.foreignKeys.mapColumn == map &&
            tool.foreignKeys.tabColumn == tab
        ).count
        
        return try dbConnection.scalar(countToolsForTabQuery)
    }
    
    // MARK: GALLERIES
    public static func countGalleriesForTool(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Int {
        let gallery = DBMS.gallery
        let countGalleriesForToolQuery = gallery.table.where(
            gallery.foreignKeys.gameColumn == game &&
            gallery.foreignKeys.mapColumn == map &&
            gallery.foreignKeys.tabColumn == tab &&
            gallery.foreignKeys.toolColumn == tool
        ).count
        
        return try dbConnection.scalar(countGalleriesForToolQuery)
    }
    
    // MARK: TOOL'S SUBGALLERIES
    public static func countSubgalleriesForTool(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Int {
        let gallery = DBMS.gallery
        let subgallery = DBMS.subgallery
        
        let subgalleriesForToolCountQuery = gallery.table.join(
            subgallery.table,
            on: gallery.table[gallery.foreignKeys.gameColumn] == subgallery.table[subgallery.foreignKeys.gameColumn] &&
            gallery.table[gallery.foreignKeys.mapColumn] == subgallery.table[subgallery.foreignKeys.mapColumn] &&
            gallery.table[gallery.foreignKeys.tabColumn] == subgallery.table[subgallery.foreignKeys.tabColumn] &&
            gallery.table[gallery.foreignKeys.toolColumn] == subgallery.table[subgallery.foreignKeys.toolColumn] &&
            gallery.nameColumn == subgallery.slaveColumn
        )
        .filter(
            gallery.table[gallery.foreignKeys.gameColumn] == game &&
            gallery.table[gallery.foreignKeys.mapColumn] == map &&
            gallery.table[gallery.foreignKeys.tabColumn] == tab &&
            gallery.table[gallery.foreignKeys.toolColumn] == tool
        ).count
        
        return try dbConnection.scalar(subgalleriesForToolCountQuery)
    }
    
    // MARK: GALLERIES' SLAVES
    public static func countSubgalleriesForGallery (
        for dbConnection: Connection,
        master: String,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Int {
        let subgallery = DBMS.subgallery
        
        let countSubgalleriesForMasterQuery = subgallery.table.where(
            subgallery.masterColumn == master &&
            subgallery.foreignKeys.gameColumn == game &&
            subgallery.foreignKeys.mapColumn == map &&
            subgallery.foreignKeys.tabColumn == tab &&
            subgallery.foreignKeys.toolColumn == tool
        ).count
        
        return try dbConnection.scalar(countSubgalleriesForMasterQuery)
    }
    
    // MARK: IMAGES FOR GALLERY
    
    /// - Note: includeVariants = true is more performant because it requires a single db read instead of two.
    public static func countImagesForGallery(
        includeVariants: Bool,
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> Int {
        
        let image = DBMS.visualMedia
        let countImagesAndVariantsForToolQuery = image.table.where(
            image.foreignKeys.gameColumn == game &&
            image.foreignKeys.mapColumn == map &&
            image.foreignKeys.tabColumn == tab &&
            image.foreignKeys.toolColumn == tool &&
            image.foreignKeys.galleryColumn == gallery
        ).count
        
        let imagesIncludingVariantsCount = try dbConnection.scalar(countImagesAndVariantsForToolQuery)
        
        if includeVariants {
            return imagesIncludingVariantsCount
        } else {
            let variant = DBMS.imageVariant
            
            let onlyVariantsCountQuery = image.table.join(
                variant.table,
                on: image.nameColumn == variant.slaveColumn &&
                image.table[image.foreignKeys.gameColumn] == variant.table[variant.foreignKeys.gameColumn] &&
                image.table[image.foreignKeys.mapColumn] == variant.table[variant.foreignKeys.mapColumn] &&
                image.table[image.foreignKeys.tabColumn] == variant.table[variant.foreignKeys.tabColumn] &&
                image.table[image.foreignKeys.toolColumn] == variant.table[variant.foreignKeys.toolColumn] &&
                image.table[image.foreignKeys.galleryColumn] == variant.table[variant.foreignKeys.galleryColumn]
            )
            .filter(
                image.table[image.foreignKeys.gameColumn] == game &&
                image.table[image.foreignKeys.mapColumn] == map &&
                image.table[image.foreignKeys.tabColumn] == tab &&
                image.table[image.foreignKeys.toolColumn] == tool &&
                image.table[image.foreignKeys.galleryColumn] == gallery
            ).count
            
            let onlyVariantsCount = try dbConnection.scalar(onlyVariantsCountQuery)
                                    
            return imagesIncludingVariantsCount - onlyVariantsCount
        }
    }
    
    // MARK: VARIANTS FOR IMAGE
    public static func countVariantsForImage(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
        image: String
    ) throws -> Int {
        let variant = DBMS.imageVariant
        let countVariantsForImageQuery = variant.table.where(
            variant.masterColumn == image &&
            variant.foreignKeys.gameColumn == game &&
            variant.foreignKeys.mapColumn == map &&
            variant.foreignKeys.tabColumn == tab &&
            variant.foreignKeys.toolColumn == tool &&
            variant.foreignKeys.galleryColumn == gallery
        ).count
        
        return try dbConnection.scalar(countVariantsForImageQuery)
    }
    
    // MARK: OUTLINES FOR IMAGE
    public static func countOutlinesForImage(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
        image: String
    ) throws -> Int {
        let outline = DBMS.outline
        let countOutlinesForImageQuery = outline.table.where(
            outline.foreignKeys.gameColumn == game &&
            outline.foreignKeys.mapColumn == map &&
            outline.foreignKeys.tabColumn == tab &&
            outline.foreignKeys.toolColumn == tool &&
            outline.foreignKeys.galleryColumn == gallery &&
            outline.foreignKeys.imageColumn == image
        ).count
        
        return try dbConnection.scalar(countOutlinesForImageQuery)
    }

    // MARK: BOUNDING CIRCLES FOR IMAGE
    public static func countBoundingCirclesForImage(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
        image: String
    ) throws -> Int {
        let boundingCircle = DBMS.boundingCircle
        let countBoundingCirclesForImageQuery = boundingCircle.table.where(
            boundingCircle.foreignKeys.gameColumn == game &&
            boundingCircle.foreignKeys.mapColumn == map &&
            boundingCircle.foreignKeys.tabColumn == tab &&
            boundingCircle.foreignKeys.toolColumn == tool &&
            boundingCircle.foreignKeys.galleryColumn == gallery &&
            boundingCircle.foreignKeys.imageColumn == image
        ).count
        
        return try dbConnection.scalar(countBoundingCirclesForImageQuery)
    }
    
    // MARK: LABELS CIRCLES FOR IMAGE
    public static func countLabelsForImage(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
        image: String
    ) throws -> Int {
        let label = DBMS.label
        let countLabelsForImageQuery = label.table.where(
            label.foreignKeys.gameColumn == game &&
            label.foreignKeys.mapColumn == map &&
            label.foreignKeys.tabColumn == tab &&
            label.foreignKeys.toolColumn == tool &&
            label.foreignKeys.galleryColumn == gallery &&
            label.foreignKeys.imageColumn == image
        ).count
        
        return try dbConnection.scalar(countLabelsForImageQuery)
    }
    
    // MARK: OVERLAYS FOR IMAGE
    public static func countOverlaysForImage(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
        image: String
    ) throws -> Int {
        let outline = DBMS.outline
        let boundingCircle = DBMS.boundingCircle
        let label = DBMS.label

        return try DBMS.performCountStatement(
            for: dbConnection.handle,
            query: """
            WITH AGGREGATED_COUNTS(Counts) AS (
                SELECT COUNT(*) AS Counts
                FROM \(outline.tableName)
                WHERE
                    \(outline.tableName).\(outline.foreignKeys.gameColumn) = \(game.withQuotes()) AND
                    \(outline.tableName).\(outline.foreignKeys.mapColumn) = \(map.withQuotes()) AND
                    \(outline.tableName).\(outline.foreignKeys.tabColumn) = \(tab.withQuotes()) AND
                    \(outline.tableName).\(outline.foreignKeys.toolColumn) = \(tool.withQuotes()) AND
                    \(outline.tableName).\(outline.foreignKeys.galleryColumn) = \(gallery.withQuotes()) AND
                    \(outline.tableName).\(outline.foreignKeys.imageColumn) = \(image.withQuotes())
                UNION ALL
                SELECT COUNT(*) AS Counts
                FROM \(boundingCircle.tableName)
                WHERE
                    \(boundingCircle.tableName).\(boundingCircle.foreignKeys.gameColumn) = \(game.withQuotes()) AND
                    \(boundingCircle.tableName).\(boundingCircle.foreignKeys.mapColumn) = \(map.withQuotes()) AND
                    \(boundingCircle.tableName).\(boundingCircle.foreignKeys.tabColumn) = \(tab.withQuotes()) AND
                    \(boundingCircle.tableName).\(boundingCircle.foreignKeys.toolColumn) = \(tool.withQuotes()) AND
                    \(boundingCircle.tableName).\(boundingCircle.foreignKeys.galleryColumn) = \(gallery.withQuotes()) AND
                    \(boundingCircle.tableName).\(boundingCircle.foreignKeys.imageColumn) = \(image.withQuotes())
                UNION ALL
                SELECT COUNT(*) AS Counts
                FROM \(label.tableName)
                WHERE
                    \(label.tableName).\(label.foreignKeys.gameColumn) = \(game.withQuotes()) AND
                    \(label.tableName).\(label.foreignKeys.mapColumn) = \(map.withQuotes()) AND
                    \(label.tableName).\(label.foreignKeys.tabColumn) = \(tab.withQuotes()) AND
                    \(label.tableName).\(label.foreignKeys.toolColumn) = \(tool.withQuotes()) AND
                    \(label.tableName).\(label.foreignKeys.galleryColumn) = \(gallery.withQuotes()) AND
                    \(label.tableName).\(label.foreignKeys.imageColumn) = \(image.withQuotes())
            )

            SELECT SUM(Counts) AS TotalCount
            FROM AGGREGATED_COUNTS;
        """
        )
    }
}


