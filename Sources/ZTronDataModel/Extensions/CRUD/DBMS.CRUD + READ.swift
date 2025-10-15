import Foundation
import SQLite3
import SQLite

extension String: ReadImageOptional { }
extension String: ReadGalleryOptional {  }

extension DBMS.CRUD {
    // MARK: - READ GAMES
    internal static func readGamePosition(
        for dbConnection: Connection,
        game: String,
    ) throws -> Int? {
        let gameTable = DBMS.game
        
        let findMapQuery = gameTable.table.filter(
            gameTable.nameColumn == game.lowercased()
        )
        
        let positions = try dbConnection.prepare(findMapQuery).map { result in
            return result[gameTable.positionColumn]
        }
        
        assert(positions.count <= 1)
        
        return positions.first
    }
    
    
    public static func readAllGames(
        for dbConnection: Connection,
        options: Set<ReadGamesOption> = Set<ReadGamesOption>([.games])
    ) throws -> [ReadGamesOption: [(any ReadGameOptional)?]] {
        let gameModel = DBMS.game
        
        let theGames = try dbConnection.prepare(gameModel.table.order(gameModel.positionColumn)).map { resultRow in
            return SerializedGameModel(resultRow)
        }
        
        var result = [ReadGamesOption: [(any ReadGameOptional)?]].init()
        
        result[.games] = theGames
        
        if options.contains(.numberOfMaps) {
            result[.numberOfMaps] = []
            for game in theGames {
                try result[.numberOfMaps]?.append(DBMS.CRUD.countMapsForGame(for: dbConnection, game: game.getName()))
            }
        }
        
        return result
    }

    
    // MARK: - READ MAPS
    internal static func readMapPosition(
        for dbConnection: Connection,
        game: String,
        map: String,
    ) throws -> Int? {
        let mapTable = DBMS.map
        
        let findMapQuery = mapTable.table.filter(
            mapTable.nameColumn == map.lowercased() &&
            mapTable.foreignKeys.gameColumn == game.lowercased()
        )
        
        let positions = try dbConnection.prepare(findMapQuery).map { result in
            return result[mapTable.positionColumn]
        }
        
        assert(positions.count <= 1)
        
        return positions.first
    }
    
    
    internal static func readMapMaster(
        for dbConnection: Connection,
        map: String,
        game: String,
    ) throws -> SerializedMapModel? {
        let submaps = DBMS.hasSubmap
        
        let findMapQuery = submaps.table.filter(
            submaps.slaveColumn == map.lowercased() &&
            submaps.foreignKeys.gameColumn == game.lowercased()
        )
        
        let masters = try dbConnection.prepare(findMapQuery).map { result in
            return SerializedMapModel(result)
        }
        
        assert(masters.count <= 1)
        
        return masters.first
    }
    
    
    public static func readAllMaps(
        for dbConnection: Connection,
        game: String,
        options: Set<ReadMapOptions> = Set<ReadMapOptions>([.maps]),
        limitToFirstLevelMasters: Bool = false
    ) throws -> [ReadMapOptions: [(any ReadMapOptional)?]] {
        let mapModel = DBMS.map
        let submapModel = DBMS.hasSubmap
        
        var slaves: [String]? = nil
        
        if limitToFirstLevelMasters {
            let findSlavesQuery = submapModel.table
                .select(submapModel.slaveColumn)
                .filter(submapModel.foreignKeys.gameColumn == game)
            
            
            slaves = try dbConnection.prepare(findSlavesQuery).map { result in
                return result[submapModel.slaveColumn]
            }
        }
        
        var findMapsQuery: Table
        
        if let slaves = slaves {
            findMapsQuery = mapModel.table.filter(mapModel.foreignKeys.gameColumn == game && !slaves.contains(mapModel.nameColumn)).order(mapModel.positionColumn)
        } else {
            findMapsQuery = mapModel.table.filter(mapModel.foreignKeys.gameColumn == game).order(mapModel.positionColumn)
        }
        
        
        let theMaps = try dbConnection.prepare(findMapsQuery).map { resultRow in
            return SerializedMapModel(resultRow)
        }

        var result = [ReadMapOptions: [(any ReadMapOptional)?]].init()
        
        result[.maps] = theMaps
        
        if options.contains(.numberOfSlaves) {
            result[.numberOfSlaves] = []
            for map in theMaps {
                try result[.numberOfSlaves]?.append(DBMS.CRUD.countSubmapsForMap(for: dbConnection, map: map.getName(), game: map.getGame()))
            }
        }
        
        
        if options.contains(.numberOfTabs) {
            result[.numberOfTabs] = []
            for map in theMaps {
                try result[.numberOfTabs]?.append(DBMS.CRUD.countTabsForMap(for: dbConnection, map: map.getName(), game: map.getGame()))
            }
        }
        
        
        if options.contains(.numberOfTools) {
            result[.numberOfTools] = []
            for map in theMaps {
                try result[.numberOfTools]?.append(DBMS.CRUD.countToolsForMap(for: dbConnection, map: map.getName(), game: map.getGame()))
            }
        }
        
        return result
    }


    public static func readAllSubmaps(
        for dbConnection: Connection,
        master: String,
        game: String,
        options: Set<ReadMapOptions> = Set<ReadMapOptions>([.maps]),
        limitToFirstLevelMasters: Bool = false
    ) throws -> [ReadMapOptions: [(any ReadMapOptional)?]] {
        let mapModel = DBMS.map
        let submapModel = DBMS.hasSubmap
        
        var slaves: [String]
        
        let findSlavesQuery = submapModel.table
            .select(submapModel.slaveColumn)
            .filter(submapModel.foreignKeys.gameColumn == game && submapModel.masterColumn == master)
        
        
        slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[submapModel.slaveColumn]
        }
        
        let findMapsQuery: Table =
                mapModel.table
                    .filter(
                        mapModel.foreignKeys.gameColumn == game &&
                        slaves.contains(mapModel.nameColumn)
                    )
                    .order(mapModel.positionColumn
                )

        
        let theMaps = try dbConnection.prepare(findMapsQuery).map { resultRow in
            return SerializedMapModel(resultRow)
        }

        var result = [ReadMapOptions: [(any ReadMapOptional)?]].init()
        
        result[.maps] = theMaps
        
        if options.contains(.numberOfSlaves) {
            result[.numberOfSlaves] = []
            for map in theMaps {
                try result[.numberOfSlaves]?.append(DBMS.CRUD.countSubmapsForMap(for: dbConnection, map: map.getName(), game: map.getGame()))
            }
        }
        
        
        if options.contains(.numberOfTabs) {
            result[.numberOfTabs] = []
            for map in theMaps {
                try result[.numberOfTabs]?.append(DBMS.CRUD.countTabsForMap(for: dbConnection, map: map.getName(), game: map.getGame()))
            }
        }
        
        
        if options.contains(.numberOfTools) {
            result[.numberOfTools] = []
            for map in theMaps {
                try result[.numberOfTools]?.append(DBMS.CRUD.countToolsForMap(for: dbConnection, map: map.getName(), game: map.getGame()))
            }
        }
        
        return result
    }

    
    internal static func readSubmapsTree(
        for dbConnection: Connection,
        master: String,
        game: String,
    ) throws -> [SerializedMapModel] {
        let mapTable = DBMS.map
        let slavesTable = DBMS.hasSubmap
        
        let findAllSubgalleriesQuery: String = """
        WITH RECURSIVE SubtreeOfMap AS (
            SELECT
                \(mapTable.tableName).\(mapTable.nameColumn.template),
                \(mapTable.tableName).\(mapTable.positionColumn.template),
                \(mapTable.tableName).\(mapTable.assetsImageNameColumn.template),
                \(mapTable.tableName).\(mapTable.foreignKeys.gameColumn.template)
            FROM \(mapTable.tableName)
            WHERE
                \(mapTable.tableName).\(mapTable.nameColumn.template) = "\(master.lowercased())"
                AND \(mapTable.tableName).\(mapTable.foreignKeys.gameColumn.template) = "\(game.lowercased())"

            UNION ALL

            SELECT
                SUBMAP.\(mapTable.nameColumn.template),
                SUBMAP.\(mapTable.positionColumn.template),
                SUBMAP.\(mapTable.assetsImageNameColumn.template),
                SUBMAP.\(mapTable.foreignKeys.gameColumn.template)
            FROM
                \(mapTable.tableName) SUBMAP
            INNER JOIN \(slavesTable.tableName) ON
                \(slavesTable.tableName).\(slavesTable.slaveColumn.template) = SUBMAP.\(mapTable.nameColumn.template)
                AND \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template) = SUBMAP.\(mapTable.foreignKeys.gameColumn.template)
            INNER JOIN SubtreeOfMap ON 
                        SubtreeOfMap.\(mapTable.nameColumn.template
        ) = \(slavesTable.tableName).\(slavesTable.masterColumn.template)
                AND SubtreeOfMap.\(mapTable.foreignKeys.gameColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template)
        )
        SELECT * FROM SubtreeOfMap;
        """
        
        var statement: OpaquePointer?
        
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_prepare_v2(dbConnection.handle, findAllSubgalleriesQuery, -1, &statement, nil) == SQLITE_OK {
            var submaps: [SerializedMapModel] = []
            
            while sqlite3_step(statement) == SQLITE_ROW {
                /*
                 Column 0: name String
                 Column 1: position Int
                 Column 2: assetsImageName: String
                 Column 3: game: String
                 */
                
                let nameColumn = String(cString: sqlite3_column_text(statement, 0))
                let positionColumn = sqlite3_column_int(statement, 1)
                let assetsImageNameColumn = String(cString: sqlite3_column_text(statement,2))
                let gameColumn = String(cString: sqlite3_column_text(statement, 3))
                
                submaps.append(SerializedMapModel(
                    name: nameColumn,
                    position: Int(positionColumn),
                    assetsImageName: assetsImageNameColumn,
                    game: gameColumn
                ))
            }
            
            return submaps
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection.handle))
            throw SQLQueryError.genericError(reason: errorMessage)
        }
    }
    
    //MARK: - READ VISUAL MEDIA
    private static func _readFirstLevelMasterImagesForGallery(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String?
    ) throws -> [any SerializedVisualMediaModel] {
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
        
        if let gallery = gallery {
            findSlavesQuery = findSlavesQuery.filter(imageVariant.foreignKeys.galleryColumn == gallery)
        }
        
        let slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[imageVariant.slaveColumn]
        }
        
        var firstLevelMastersQuery = media.table.filter(
            media.foreignKeys.gameColumn == game &&
            media.foreignKeys.mapColumn == map &&
            media.foreignKeys.tabColumn == tab &&
            media.foreignKeys.toolColumn == tool &&
            !slaves.contains(media.nameColumn)
        )
        .order(media.positionColumn)
        
        if let gallery = gallery {
            firstLevelMastersQuery = firstLevelMastersQuery.filter(media.foreignKeys.galleryColumn == gallery)
        }
        
        return try dbConnection.prepare(firstLevelMastersQuery).map { mediaRow in
            if mediaRow[media.typeColumn] == "image" {
                return SerializedImageModel(mediaRow)
            } else {
                return SerializedVideoModel(mediaRow)
            }
        }
    }
    
    public static func readImageByID(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> SerializedImageModel {
        let imageModel = DBMS.visualMedia
        
        let findImageQuery = imageModel.table.filter(
            imageModel.nameColumn == image &&
            imageModel.typeColumn == "image" &&
            imageModel.foreignKeys.galleryColumn == gallery &&
            imageModel.foreignKeys.toolColumn == tool &&
            imageModel.foreignKeys.tabColumn == tab &&
            imageModel.foreignKeys.mapColumn == map &&
            imageModel.foreignKeys.gameColumn == game
        )
        
        let theImage = try dbConnection.prepare(findImageQuery).map { resultRow in
            return SerializedImageModel(resultRow)
        }
        
        assert(theImage.count == 1)
        
        return theImage.first!
    }
    
    public static func readVideoByID(
        for dbConnection: Connection,
        video: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> SerializedVideoModel {
        let videoModel = DBMS.visualMedia
        
        let findVideoQuery = videoModel .table.filter(
            videoModel.nameColumn == video &&
            videoModel.typeColumn == "video" &&
            videoModel.foreignKeys.galleryColumn == gallery &&
            videoModel.foreignKeys.toolColumn == tool &&
            videoModel.foreignKeys.tabColumn == tab &&
            videoModel.foreignKeys.mapColumn == map &&
            videoModel.foreignKeys.gameColumn == game
        )
        
        let theVideo = try dbConnection.prepare(findVideoQuery).map { resultRow in
            return SerializedVideoModel(resultRow)
        }
        
        assert(theVideo.count == 1)
        
        return theVideo.first!
    }
    
    public static func readMediaByID(
        for dbConnection: Connection,
        name: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> any SerializedVisualMediaModel {
        let mediaModel = DBMS.visualMedia
        
        let findMediaQuery = mediaModel.table.filter(
            mediaModel.nameColumn == name &&
            mediaModel.foreignKeys.galleryColumn == gallery &&
            mediaModel.foreignKeys.toolColumn == tool &&
            mediaModel.foreignKeys.tabColumn == tab &&
            mediaModel.foreignKeys.mapColumn == map &&
            mediaModel.foreignKeys.gameColumn == game
        )
        
        let theMedia: [any SerializedVisualMediaModel] = try dbConnection.prepare(findMediaQuery).map { resultRow in
            switch resultRow[mediaModel.typeColumn] {
            case "image":
                return SerializedImageModel(resultRow)
                
            case "video":
                return SerializedVideoModel(resultRow)
                
            default:
                fatalError("Unexpectedly found media of type \(resultRow[mediaModel.typeColumn]). Expected type in [\"image\", \"video\"]")
            }
            
            return SerializedVideoModel(resultRow)
        }
        assert(theMedia.count == 1)
        
        return theMedia.first!
    }
    
    
    
    public static func readImageByIDWithOptions(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        options: Set<ReadImageOption> = Set<ReadImageOption>([.medias])
    ) throws -> [ReadImageOption: [(any ReadImageOptional)?]] {
        let visualMediasTable = DBMS.visualMedia
        let imageVariants = DBMS.imageVariant
        let outline = DBMS.outline
        let boundingCircle = DBMS.boundingCircle
        let label = DBMS.label
        
        let parentView = SQLite.View("parentView")
        
        try dbConnection.run(
            parentView.create(
                visualMediasTable.table
                    .join(
                        .leftOuter,
                        imageVariants.table,
                        on: visualMediasTable.nameColumn == imageVariants.slaveColumn &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == imageVariants.table[imageVariants.foreignKeys.galleryColumn] &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == imageVariants.table[imageVariants.foreignKeys.toolColumn] &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == imageVariants.table[imageVariants.foreignKeys.tabColumn] &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == imageVariants.table[imageVariants.foreignKeys.mapColumn] &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == imageVariants.table[imageVariants.foreignKeys.gameColumn]
                    )
                    .filter(
                        visualMediasTable.nameColumn == image &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == gallery &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == tool &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == tab &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == map &&
                        visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == game
                    )
                    .select(
                        [
                            visualMediasTable.nameColumn.alias(name: "childImage"),
                            imageVariants.masterColumn.alias(name: "parent"),
                            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn],
                            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn],
                            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn],
                            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn],
                            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn]
                        ]
                    ),
                    temporary: true,
                    ifNotExists: true
                )
        )
        
        let parentViewChild = SQLite.Expression<String?>("childImage")
        let parentViewParent = SQLite.Expression<String?>("parent")
        
        defer {
            let _ = parentView.drop(ifExists: true)
        }

        
        let sql = visualMediasTable.table.join(
            .leftOuter,
            imageVariants.table,
            on: visualMediasTable.table[visualMediasTable.nameColumn] == imageVariants.table[imageVariants.masterColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == imageVariants.table[imageVariants.foreignKeys.galleryColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == imageVariants.table[imageVariants.foreignKeys.toolColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == imageVariants.table[imageVariants.foreignKeys.tabColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == imageVariants.table[imageVariants.foreignKeys.mapColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == imageVariants.table[imageVariants.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            parentView,
            on: visualMediasTable.table[visualMediasTable.nameColumn] == parentView[parentViewChild] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == parentView[visualMediasTable.foreignKeys.galleryColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == parentView[visualMediasTable.foreignKeys.toolColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == parentView[visualMediasTable.foreignKeys.tabColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == parentView[visualMediasTable.foreignKeys.mapColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == parentView[visualMediasTable.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            outline.table,
            on: visualMediasTable.table[visualMediasTable.nameColumn] == outline.table[outline.foreignKeys.imageColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == outline.table[outline.foreignKeys.galleryColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == outline.table[outline.foreignKeys.toolColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == outline.table[outline.foreignKeys.tabColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == outline.table[outline.foreignKeys.mapColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == outline.table[outline.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            boundingCircle.table,
            on: visualMediasTable.table[visualMediasTable.nameColumn] == boundingCircle.table[boundingCircle.foreignKeys.imageColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == boundingCircle.table[boundingCircle.foreignKeys.galleryColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == boundingCircle.table[boundingCircle.foreignKeys.toolColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == boundingCircle.table[boundingCircle.foreignKeys.tabColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == boundingCircle.table[boundingCircle.foreignKeys.mapColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == boundingCircle.table[boundingCircle.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            label.table,
            on: visualMediasTable.table[visualMediasTable.nameColumn] == label.table[label.foreignKeys.imageColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == label.table[label.foreignKeys.galleryColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == label.table[label.foreignKeys.toolColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == label.table[label.foreignKeys.tabColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == label.table[label.foreignKeys.mapColumn] &&
            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == label.table[label.foreignKeys.gameColumn]
        ).filter(
            visualMediasTable.table[visualMediasTable.nameColumn] == image &&
            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn] == gallery &&
            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn] == tool &&
            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn] == tab &&
            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn] == map &&
            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn] == game
        ).select(
            visualMediasTable.table[visualMediasTable.nameColumn],
            visualMediasTable.table[visualMediasTable.descriptionColumn],
            visualMediasTable.table[visualMediasTable.positionColumn],
            visualMediasTable.table[visualMediasTable.searchLabelColumn],
            imageVariants.table[imageVariants.masterColumn],
            imageVariants.table[imageVariants.slaveColumn],
            imageVariants.table[imageVariants.variantColumn],
            imageVariants.table[imageVariants.bottomBarIconColumn],
            imageVariants.table[imageVariants.goBackBottomBarIconColumn],
            imageVariants.table[imageVariants.boundingFrameOriginXColumn],
            imageVariants.table[imageVariants.boundingFrameOriginYColumn],
            imageVariants.table[imageVariants.boundingFrameWidthColumn],
            imageVariants.table[imageVariants.boundingFrameHeightColumn],
            parentView[parentViewParent],
            outline.table[outline.resourceNameColumn],
            outline.table[outline.colorHexColumn]/*.alias(name: "outlineColorHex")*/,
            outline.table[outline.opacityColumn]/*.alias(name: "outlineOpacity")*/,
            outline.table[outline.isActiveColumn]/*.alias(name: "isOutlineActive")*/,
            outline.table[outline.boundingBoxOriginXColumn]/*.alias(name: "outlineBoundingBoxOriginX")*/,
            outline.table[outline.boundingBoxOriginYColumn]/*.alias(name: "outlineBoundingBoxOriginY")*/,
            outline.table[outline.boundingBoxWidthColumn]/*.alias(name: "outlineBoundingBoxWidth")*/,
            outline.table[outline.boundingBoxHeightColumn]/*.alias(name: "outlineBoundingBoxHeight")*/,
            boundingCircle.table[boundingCircle.colorHexColumn]/*.alias(name: "boundingCircleColorHex")*/,
            boundingCircle.table[boundingCircle.opacityColumn]/*.alias(name: "boundingCircleOpacity")*/,
            boundingCircle.table[boundingCircle.isActiveColumn]/*.alias(name: "isBoundingCircleActive")*/,
            boundingCircle.table[boundingCircle.idleDiameterColumn],
            boundingCircle.table[boundingCircle.normalizedCenterXColumn],
            boundingCircle.table[boundingCircle.normalizedCenterYColumn],
            label.table[label.labelColumn],
            label.table[label.opacityColumn],
            label.table[label.isActiveColumn],
            label.table[label.iconColumn],
            label.table[label.assetsImageNameColumn],
            label.table[label.textColorHexColumn],
            label.table[label.backgroundColorHexColumn],
            label.table[label.maxAABBOriginXColumn],
            label.table[label.maxAABBOriginYColumn],
            label.table[label.maxAABBWidthColumn],
            label.table[label.maxAABBHeightColumn],
            visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn],
            visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn],
            visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn],
            visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn],
            visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn]
        )
        
        let outlineExists = SQLite.Expression<String?>(
            outline.resourceNameColumn.template.droppingQuotes()
        )
        
        let boundingCircleExists = SQLite.Expression<String?>(
            boundingCircle.colorHexColumn.template.droppingQuotes()
        )

        let labelExists = SQLite.Expression<String?>(
            label.labelColumn.template.droppingQuotes()
        )

        let variantExists = SQLite.Expression<String?>(
            imageVariants.slaveColumn.template.droppingQuotes()
        )
        
        
        var imageDictionary: [String: SerializedImageModel] = [:]
        var outlinesDictionary: [String: SerializedOutlineModel] = [:]
        var boundingCircleDictionary: [String: SerializedBoundingCircleModel] = [:]
        var labelsDictionary: [String: Set<SerializedLabelModel>] = [:]
        var variantsDictionary: [String: Set<SerializedImageVariantMetadataModel>] = [:]
        var masterDictionary: [String: String] = [:]
        
        try dbConnection.prepare(sql).forEach { result in
            let image = SerializedImageModel(result, namespaceColumns: true)
            
            let imageID = image.getName()
            
            if imageDictionary[imageID] == nil {
                imageDictionary[imageID] = image
                
                if let outlineResourceName = result[outline.table[outlineExists]] {
                    let theOutline = SerializedOutlineModel(
                        resourceName: outlineResourceName,
                        colorHex: result[outline.table[outline.colorHexColumn]],
                        isActive: result[outline.table[outline.isActiveColumn]],
                        opacity: result[outline.table[outline.opacityColumn]],
                        boundingBoxOriginXColumn: result[outline.table[outline.boundingBoxOriginXColumn]],
                        boundingBoxOriginYColumn: result[outline.table[outline.boundingBoxOriginYColumn]],
                        boundingBoxWidthColumn: result[outline.table[outline.boundingBoxWidthColumn]],
                        boundingBoxHeightColumn: result[outline.table[outline.boundingBoxHeightColumn]],
                        image: result[visualMediasTable.table[visualMediasTable.nameColumn]],
                        gallery: result[visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn]],
                        tool: result[visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn]],
                        tab: result[visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn]],
                        map: result[visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn]],
                        game: result[visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn]]
                    )
                    
                    outlinesDictionary[imageID] = theOutline
                }
                
                if let boundingCircleHex = result[boundingCircle.table[boundingCircleExists]] {
                    let theBoundingCircle = SerializedBoundingCircleModel(
                        colorHex: boundingCircleHex,
                        isActive: result[boundingCircle.table[boundingCircle.isActiveColumn]],
                        opacity: result[boundingCircle.table[boundingCircle.opacityColumn]],
                        idleDiameter: result[boundingCircle.table[boundingCircle.idleDiameterColumn]],
                        normalizedCenterX: result[boundingCircle.table[boundingCircle.normalizedCenterXColumn]],
                        normalizedCenterY: result[boundingCircle.table[boundingCircle.normalizedCenterYColumn]],
                        image: result[visualMediasTable.table[visualMediasTable.nameColumn]],
                        gallery: result[visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn]],
                        tool: result[visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn]],
                        tab: result[visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn]],
                        map: result[visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn]],
                        game: result[visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn]]
                    )
                    
                    boundingCircleDictionary[imageID] = theBoundingCircle
                }
                
                if let master = result[parentView[parentViewParent]] {
                    masterDictionary[imageID] = master
                }
            }
            
            
            if let labelColumn = result[label.table[labelExists]] {
                let theLabel = SerializedLabelModel(
                    label: labelColumn,
                    isActive: result[label.table[label.isActiveColumn]],
                    icon: result[label.table[label.iconColumn]],
                    assetsImageName: result[label.table[label.assetsImageNameColumn]],
                    textColorHex: result[label.table[label.textColorHexColumn]],
                    backgroundColorHex: result[label.table[label.backgroundColorHexColumn]],
                    opacity: result[label.table[label.opacityColumn]],
                    maxAABBOriginX: result[label.table[label.maxAABBOriginXColumn]],
                    maxAABBOriginY: result[label.table[label.maxAABBOriginYColumn]],
                    maxAABBWidth: result[label.table[label.maxAABBWidthColumn]],
                    maxAABBHeight: result[label.table[label.maxAABBHeightColumn]],
                    image: result[visualMediasTable.table[visualMediasTable.nameColumn]],
                    gallery: result[visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn]],
                    tool: result[visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn]],
                    tab: result[visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn]],
                    map: result[visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn]],
                    game: result[visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn]]
                )
                
                if labelsDictionary[imageID] == nil {
                    labelsDictionary[imageID] = Set<SerializedLabelModel>()
                }
                
                labelsDictionary[imageID]?.insert(theLabel)
            }
            
            
            if let slaveColumn = result[imageVariants.table[variantExists]] {
                let theVariant = SerializedImageVariantMetadataModel(
                    master: result[imageVariants.table[imageVariants.masterColumn]],
                    slave: slaveColumn,
                    variant: result[imageVariants.table[imageVariants.variantColumn]],
                    bottomBarIcon: result[imageVariants.table[imageVariants.bottomBarIconColumn]],
                    goBackBottomBarIcon: result[imageVariants.table[imageVariants.goBackBottomBarIconColumn]],
                    boundingFrameOriginX: result[imageVariants.table[imageVariants.boundingFrameOriginXColumn]],
                    boundingFrameOriginY: result[imageVariants.table[imageVariants.boundingFrameOriginYColumn]],
                    boundingFrameWidth: result[imageVariants.table[imageVariants.boundingFrameWidthColumn]],
                    boundingFrameHeight: result[imageVariants.table[imageVariants.boundingFrameHeightColumn]],
                    gallery: result[visualMediasTable.table[visualMediasTable.foreignKeys.galleryColumn]],
                    tool: result[visualMediasTable.table[visualMediasTable.foreignKeys.toolColumn]],
                    tab: result[visualMediasTable.table[visualMediasTable.foreignKeys.tabColumn]],
                    map: result[visualMediasTable.table[visualMediasTable.foreignKeys.mapColumn]],
                    game: result[visualMediasTable.table[visualMediasTable.foreignKeys.gameColumn]]
                )
                
                if variantsDictionary[imageID] == nil {
                    variantsDictionary[imageID] = Set<SerializedImageVariantMetadataModel>()
                }
                
                variantsDictionary[imageID]?.insert(theVariant)
            }
        }
        
        var result: [ReadImageOption: [(any ReadImageOptional)?]] = [:]
        
        imageDictionary.keys.forEach { imageID in
            guard let image = imageDictionary[image] else { fatalError() }
            result[.medias] = [image]
            
            if options.contains(.outlines) {
                if let outline = outlinesDictionary[imageID] {
                    result[.outlines] = [outline]
                }
            }
            
            if options.contains(.boundingCircles) {
                if let boundingCircle = boundingCircleDictionary[imageID] {
                    result[.boundingCircles] = [boundingCircle]
                }
            }
            
            if options.contains(.labels) {
                if let labels = labelsDictionary[imageID] {
                    result[.labels] = [SerializedLabelsSet(labels: Array(labels))]
                }
            }
            
            if options.contains(.variantsMetadatas) {
                if let variants = variantsDictionary[imageID] {
                    result[.variantsMetadatas] = [SerializedImageVariantsMetadataSet(variants: Array(variants))]
                }
            }
            
            if options.contains(.masters) {
                if result[.masters] == nil {
                    result[.masters] = []
                }
                
                result[.masters]?.append(masterDictionary[imageID])
            }

        }

        assert(result[.medias]?.count ?? 0 == 1)
        assert(result[.outlines]?.count ?? 0 <= 1)
        assert(result[.boundingCircles]?.count ?? 0 <= 1)
        assert(result[.labels]?.count ?? 0 <= 1)
        assert(result[.variantsMetadatas]?.count ?? 0 <= 1)
        assert(result[.masters]?.count ?? 0 <= 1)
        
        return result
    }
    
    private static func readOutlinesForMediasSet(for dbConnection: Connection, medias: [any SerializedVisualMediaModel]) throws -> [SerializedOutlineModel?] {
        let outline = DBMS.outline
        
        var outlines: [SerializedOutlineModel?] = []
        
        for media in medias {
            if media.getType() == .image {
                let outlinesForThisImageQuery = outline.table.filter(
                    outline.foreignKeys.imageColumn == media.getName() &&
                    outline.foreignKeys.galleryColumn == media.getGallery() &&
                    outline.foreignKeys.toolColumn == media.getTool() &&
                    outline.foreignKeys.tabColumn == media.getTab() &&
                    outline.foreignKeys.mapColumn == media.getMap() &&
                    outline.foreignKeys.gameColumn == media.getGame()
                )
                
                let outlinesForThisImage = try dbConnection.prepare(outlinesForThisImageQuery)
                var countOutlines = 0
                
                for outlineRow in outlinesForThisImage {
                    countOutlines += 1
                    outlines.append(SerializedOutlineModel(outlineRow))
                }
                
                if countOutlines <= 0 {
                    outlines.append(nil)
                }
            } else {
                outlines.append(nil)
            }
        }
        
        return outlines
    }

    internal static func readBoundingCirclesForMediasSet(for dbConnection: Connection, medias: [any SerializedVisualMediaModel]) throws -> [SerializedBoundingCircleModel?] {
        let boundingCircle = DBMS.boundingCircle
        
        var boundingCircles: [SerializedBoundingCircleModel?] = []
        
        for media in medias {
            if media.getType() == .image {
                let boundingCirclesForThisImageQuery = boundingCircle.table.filter(
                    boundingCircle.foreignKeys.imageColumn == media.getName() &&
                    boundingCircle.foreignKeys.galleryColumn == media.getGallery() &&
                    boundingCircle.foreignKeys.toolColumn == media.getTool() &&
                    boundingCircle.foreignKeys.tabColumn == media.getTab() &&
                    boundingCircle.foreignKeys.mapColumn == media.getMap() &&
                    boundingCircle.foreignKeys.gameColumn == media.getGame()
                )
                
                let boundingCirclesForThisImage = try dbConnection.prepare(boundingCirclesForThisImageQuery)
                var countBoundingCircles = 0
                
                for boundingCircle in boundingCirclesForThisImage {
                    countBoundingCircles += 1
                    boundingCircles.append(SerializedBoundingCircleModel(boundingCircle))
                }
                
                if countBoundingCircles <= 0 {
                    boundingCircles.append(nil)
                }
            } else {
                boundingCircles.append(nil)
            }
        }
        
        return boundingCircles
    }
    
    private static func readLabelsForMediasSet(for dbConnection: Connection, medias: [any SerializedVisualMediaModel]) throws -> [SerializedLabelsSet?] {
        let label = DBMS.label
        
        var labels: [SerializedLabelsSet?] = []
        
        for media in medias {
            if media.getType() == .image {
                let labelsForThisImageQuery = label.table.filter(
                    label.foreignKeys.imageColumn == media.getName() &&
                    label.foreignKeys.galleryColumn == media.getGallery() &&
                    label.foreignKeys.toolColumn == media.getTool() &&
                    label.foreignKeys.tabColumn == media.getTab() &&
                    label.foreignKeys.mapColumn == media.getMap() &&
                    label.foreignKeys.gameColumn == media.getGame()
                )
                
                let labelsForThisImage = try dbConnection.prepare(labelsForThisImageQuery)
                
                var iLabels = [SerializedLabelModel].init()
                
                for label in labelsForThisImage {
                    iLabels.append(SerializedLabelModel(label))
                }
                
                if iLabels.count <= 0 {
                    labels.append(nil)
                } else {
                    labels.append(SerializedLabelsSet(labels: iLabels))
                }
            } else {
                labels.append(nil)
            }
        }
        
        return labels
    }
    
    
    internal static func readVariantsMetadataForMediasSet(for dbConnection: Connection, medias: [any SerializedVisualMediaModel]) throws -> [SerializedImageVariantsMetadataSet?] {
        let variant = DBMS.imageVariant
        
        var variants: [SerializedImageVariantsMetadataSet?] = []
        
        for media in medias.enumerated() {
            if media.element.getType() == .image {
                let variantsForThisImageQuery = variant.table.filter(
                    variant.masterColumn == media.element.getName() &&
                    variant.foreignKeys.galleryColumn == media.element.getGallery() &&
                    variant.foreignKeys.toolColumn == media.element.getTool() &&
                    variant.foreignKeys.tabColumn == media.element.getTab() &&
                    variant.foreignKeys.mapColumn == media.element.getMap() &&
                    variant.foreignKeys.gameColumn == media.element.getGame()
                )
                
                let variantsForThisImage = try dbConnection.prepare(variantsForThisImageQuery)
                var iVariants: [SerializedImageVariantMetadataModel] = []
                
                for variant in variantsForThisImage {
                    iVariants.append(SerializedImageVariantMetadataModel(variant))
                }
                
                if iVariants.count <= 0 {
                    variants.append(nil)
                } else {
                    variants.append(SerializedImageVariantsMetadataSet(variants: iVariants))
                }
            } else {
                variants.append(nil)
            }
        }
        
        return variants
    }
    
    /// Returns from database the set of all the top level `master`s for the specified gallery, along with the requested optionals.
    ///
    /// - Parameter gallery: The name of the gallery to load master images for. If `nil`, all the images for the tool are loaded instead
    /// - Optionals:
    ///     - **images**: This is always included. The images models are always included regardless of whether or not you explicitly include this option. Also,
    ///     the associated array never contains optionals, so it's safe to cast to `[SerializedImageModel]`.
    ///     - **outlines**: If included, a set of all the outlines for each image in `.images` will be included under `.outlines`. If an image doesn't have an outline
    ///     associated with it, a `nil` value will be included instead. The result is safe to cast to `[SerializedOutlineModel?]`.
    ///     - **boundingCircles** : If included, a set of all the bounding circles for each image in `.images` will be included under `.boundingCircles`. If an image doesn't
    ///     have a bounding circle associated with it, a `nil` value will be included instead. The result is safe to cast to `[SerializedBoundingCircleModel?]`.
    ///     - **labels**: If included, a set of all the labels for each image in `.images` will be included under `.labels`. If an image doesn't
    ///     have any label associated with it, a `nil` value will be included instead. The result is safe to cast to `[SerializedLabelsSet?]`.
    ///     - **variantsMetadatas**: If included, a set of all the metadata for variants of each image in `.images` will be included under `.variantsMetadata`.
    ///      If an image doesn't have any variant associated with it, a `nil` value will be included instead.
    ///      The result is safe to cast to `[SerializedImageVariantsMetadataSet?]`.
    ///
    /// If an option is not included, the associated value in the returned dictionary will be `nil`. This way, it is guaranteed that when an array is not `nil`, it will have the same
    /// size as `.images`.
    ///
    /// The association between an image and its outline, bounding circle, label and so on, is by index. This means that the outline for the first image in `.images` will
    /// take the first position in `.outlines` and so on.
    public static func readFirstLevelMasterImagesForGallery(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String?,
        options: Set<ReadImageOption> = Set<ReadImageOption>([.medias])
    ) throws -> [ReadImageOption: [(any ReadImageOptional)?]] {
        var imagesWithOptionals: [ReadImageOption: [(any ReadImageOptional)?]] = [:]
        
        let medias = try self._readFirstLevelMasterImagesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: gallery
        )
        
        if options.contains(.outlines) {
            imagesWithOptionals[.outlines] = try self.readOutlinesForMediasSet(for: dbConnection, medias: medias)
        }
        
        if options.contains(.boundingCircles) {
            imagesWithOptionals[.boundingCircles] = try self.readBoundingCirclesForMediasSet(
                for: dbConnection,
                medias: medias
            )
        }
        
        if options.contains(.labels) {
            imagesWithOptionals[.labels] = try self.readLabelsForMediasSet(for: dbConnection, medias: medias)
        }
        
        if options.contains(.variantsMetadatas) {
            imagesWithOptionals[.variantsMetadatas] = try self.readVariantsMetadataForMediasSet(
                for: dbConnection,
                medias: medias
            )
        }
        
        if options.contains(.masters) {
            imagesWithOptionals[.masters] = [String?].init(repeating: nil, count: medias.count)
        }
        
        imagesWithOptionals[.medias] = medias
        
        return imagesWithOptionals
    }
    
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    internal static func readImageMaster(
        for dbConnection: Connection,
        slave: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> (any SerializedVisualMediaModel)? {
        let slavesTable = DBMS.imageVariant
        let imagesTable = DBMS.visualMedia
        
        let findMasterQuery = imagesTable.table
            .select(
                imagesTable.nameColumn,
                imagesTable.descriptionColumn,
                imagesTable.positionColumn,
                imagesTable.searchLabelColumn,
                imagesTable.typeColumn,
                imagesTable.extensionColumn,
                imagesTable.foreignKeys.gameColumn,
                imagesTable.foreignKeys.mapColumn,
                imagesTable.foreignKeys.tabColumn,
                imagesTable.foreignKeys.toolColumn,
                imagesTable.foreignKeys.galleryColumn,
            )
            .join(
                slavesTable.table,
                on: slavesTable.slaveColumn == slave &&
                slavesTable.masterColumn == imagesTable.nameColumn &&
                slavesTable.foreignKeys.gameColumn == imagesTable.foreignKeys.gameColumn &&
                slavesTable.foreignKeys.mapColumn == imagesTable.foreignKeys.mapColumn &&
                slavesTable.foreignKeys.tabColumn == imagesTable.foreignKeys.tabColumn &&
                slavesTable.foreignKeys.toolColumn == imagesTable.foreignKeys.toolColumn &&
                slavesTable.foreignKeys.galleryColumn == imagesTable.foreignKeys.galleryColumn
        )
        
        let masters: [any SerializedVisualMediaModel] = try dbConnection.prepare(findMasterQuery).map { result in
            switch result[imagesTable.typeColumn] {
            case "image":
                return SerializedImageModel(result)
                
            case "video":
                return SerializedVideoModel(result)
                
            default:
                fatalError("Unable to make READ model for media of type \(result[imagesTable.typeColumn])")
            }
        }

        assert(masters.count <= 0)
        return masters.first
    }
    
    /// Reads the first level of slave visual medias for the specified master
    ///
    /// - `VisualMedia(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    internal static func readAllVariants(
        for dbConnection: Connection,
        master: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> [any SerializedVisualMediaModel] {
        let slavesTable = DBMS.imageVariant
        let imagesTable = DBMS.visualMedia
        
        let findSlavesQuery = imagesTable.table
            .select(
                imagesTable.table[imagesTable.nameColumn],
                imagesTable.table[imagesTable.descriptionColumn],
                imagesTable.table[imagesTable.positionColumn],
                imagesTable.table[imagesTable.searchLabelColumn],
                imagesTable.table[imagesTable.typeColumn],
                imagesTable.table[imagesTable.extensionColumn],
                imagesTable.table[imagesTable.foreignKeys.gameColumn],
                imagesTable.table[imagesTable.foreignKeys.mapColumn],
                imagesTable.table[imagesTable.foreignKeys.tabColumn],
                imagesTable.table[imagesTable.foreignKeys.toolColumn],
                imagesTable.table[imagesTable.foreignKeys.galleryColumn],
            )
            .join(
                slavesTable.table,
                on: slavesTable.table[slavesTable.slaveColumn] == imagesTable.table[imagesTable.nameColumn] &&
                slavesTable.table[slavesTable.foreignKeys.gameColumn] == imagesTable.table[imagesTable.foreignKeys.gameColumn] &&
                slavesTable.table[slavesTable.foreignKeys.mapColumn] == imagesTable.table[imagesTable.foreignKeys.mapColumn] &&
                slavesTable.table[slavesTable.foreignKeys.tabColumn] == imagesTable.table[imagesTable.foreignKeys.tabColumn] &&
                slavesTable.table[slavesTable.foreignKeys.toolColumn] == imagesTable.table[imagesTable.foreignKeys.toolColumn] &&
                slavesTable.table[slavesTable.foreignKeys.galleryColumn] == imagesTable.table[imagesTable.foreignKeys.galleryColumn]
            )
            .filter(
                slavesTable.table[slavesTable.foreignKeys.gameColumn] == game.lowercased() &&
                slavesTable.table[slavesTable.foreignKeys.mapColumn] == map.lowercased() &&
                slavesTable.table[slavesTable.foreignKeys.tabColumn] == tab.lowercased() &&
                slavesTable.table[slavesTable.foreignKeys.toolColumn] == tool.lowercased() &&
                slavesTable.table[slavesTable.foreignKeys.galleryColumn] == gallery.lowercased() &&
                slavesTable.table[slavesTable.masterColumn] == master.lowercased()
            )
            .order(imagesTable.table[imagesTable.positionColumn])
        
        
        let variants: [any SerializedVisualMediaModel] = try dbConnection.prepare(findSlavesQuery).map { result in
            switch result[imagesTable.typeColumn] {
                case "image":
                    return SerializedImageModel(result, namespaceColumns: true)
                    
                case "video":
                    return SerializedVideoModel(result, namespaceColumns: true)
                    
                default:
                    fatalError("Unable to create serialized READ model from type \(result[imagesTable.typeColumn])")
                }
        }
        
        return variants
    }
    
    
    internal static func readImagePosition(
        for dbConnection: Connection,
        image: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> Int? {
        let visualMediaTable = DBMS.visualMedia
        
        let findImageQuery = visualMediaTable.table.filter(
            visualMediaTable.nameColumn == image.lowercased() &&
            visualMediaTable.foreignKeys.gameColumn == game.lowercased() &&
            visualMediaTable.foreignKeys.mapColumn == map.lowercased() &&
            visualMediaTable.foreignKeys.tabColumn == tab.lowercased() &&
            visualMediaTable.foreignKeys.toolColumn == tool.lowercased() &&
            visualMediaTable.foreignKeys.galleryColumn == gallery.lowercased()
        )
        
        
        let positions = try dbConnection.prepare(findImageQuery).map { result in
            return result[visualMediaTable.positionColumn]
        }
        
        assert(positions.count <= 1)
        
        return positions.first
    }
    
    //MARK: - READ FIRST LAYER OF GALLERIES
    private static func readFirstLevelOfGalleriesForTool(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> [SerializedGalleryModel] {
        let gallery = DBMS.gallery
        let subgallery = DBMS.subgallery
        
        let findSlavesQuery = subgallery.table
            .select(subgallery.slaveColumn)
            .filter(
                subgallery.foreignKeys.gameColumn == game &&
                subgallery.foreignKeys.mapColumn == map &&
                subgallery.foreignKeys.tabColumn == tab &&
                subgallery.foreignKeys.toolColumn == tool
            )
        
        let slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[subgallery.slaveColumn]
        }
        
        let firstLevelMastersQuery = gallery.table.filter(
            gallery.foreignKeys.gameColumn == game &&
            gallery.foreignKeys.mapColumn == map &&
            gallery.foreignKeys.tabColumn == tab &&
            gallery.foreignKeys.toolColumn == tool &&
            !slaves.contains(gallery.nameColumn)
        )
        .order(gallery.positionColumn)
        
        return try dbConnection.prepare(firstLevelMastersQuery).map { galleryRow in
            return SerializedGalleryModel(galleryRow)
        }
    }
    
    // TODO: Accomodate for new ReadGalleryOptions
    public static func readAllGalleriesForTool(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
        options: Set<ReadGalleryOption> = [.galleries]
    ) throws -> [ReadGalleryOption: [(any ReadGalleryOptional)?]] {
        
        let masterSlavesGalleriesView: SQLite.View = .init("parentView")
        let gallery = DBMS.gallery
        let subgalleries = DBMS.subgallery
        let searchToken = DBMS.gallerySearchToken
        
        try dbConnection.run(
            masterSlavesGalleriesView.create(
                gallery.table.join(
                    .leftOuter,
                    subgalleries.table,
                    on: gallery.table[gallery.nameColumn] == subgalleries.table[subgalleries.slaveColumn] &&
                    gallery.table[gallery.foreignKeys.toolColumn] == subgalleries.table[subgalleries.foreignKeys.toolColumn] &&
                    gallery.table[gallery.foreignKeys.tabColumn] == subgalleries.table[subgalleries.foreignKeys.tabColumn] &&
                    gallery.table[gallery.foreignKeys.mapColumn] == subgalleries.table[subgalleries.foreignKeys.mapColumn] &&
                    gallery.table[gallery.foreignKeys.gameColumn] == subgalleries.table[subgalleries.foreignKeys.gameColumn]
                )
                .filter(
                    gallery.table[gallery.foreignKeys.toolColumn] == tool &&
                    gallery.table[gallery.foreignKeys.tabColumn] == tab &&
                    gallery.table[gallery.foreignKeys.mapColumn] == map &&
                    gallery.table[gallery.foreignKeys.gameColumn] == game
                )
                .select(
                    gallery.table[*],
                    subgalleries.table[subgalleries.masterColumn].alias(name: "master")
                ),
                temporary: true,
                ifNotExists: true
            )
        )
        
        defer {
            let _ = masterSlavesGalleriesView.drop(ifExists: true)
        }
        
        let findGalleriesQuery = gallery.table.join(
            masterSlavesGalleriesView,
            on: masterSlavesGalleriesView[gallery.foreignKeys.toolColumn] == gallery.table[gallery.foreignKeys.toolColumn] &&
            masterSlavesGalleriesView[gallery.foreignKeys.tabColumn] == gallery.table[gallery.foreignKeys.tabColumn] &&
            masterSlavesGalleriesView[gallery.foreignKeys.mapColumn] == gallery.table[gallery.foreignKeys.mapColumn] &&
            masterSlavesGalleriesView[gallery.foreignKeys.gameColumn] == gallery.table[gallery.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            searchToken.table,
            on: gallery.table[gallery.nameColumn] == searchToken.table[searchToken.foreignKeys.galleryColumn] &&
            gallery.table[gallery.foreignKeys.toolColumn] == searchToken.table[searchToken.foreignKeys.toolColumn] &&
            gallery.table[gallery.foreignKeys.tabColumn] == searchToken.table[searchToken.foreignKeys.tabColumn] &&
            gallery.table[gallery.foreignKeys.mapColumn] == searchToken.table[searchToken.foreignKeys.mapColumn] &&
            gallery.table[gallery.foreignKeys.gameColumn] == searchToken.table[searchToken.foreignKeys.gameColumn]
        )
        .filter(
            masterSlavesGalleriesView[gallery.nameColumn] == gallery.table[gallery.nameColumn] &&
            gallery.table[gallery.foreignKeys.toolColumn] == tool &&
            gallery.table[gallery.foreignKeys.tabColumn] == tab &&
            gallery.table[gallery.foreignKeys.mapColumn] == map &&
            gallery.table[gallery.foreignKeys.gameColumn] == game
        )
        .order(gallery.table[gallery.positionColumn])
        .select(
            gallery.table[*],
            masterSlavesGalleriesView[SQLite.Expression<String?>("master")],
            searchToken.table[searchToken.titleColumn],
            searchToken.table[searchToken.iconColumn],
            searchToken.table[searchToken.iconColorHexColumn]
        )

        
        var result: [ReadGalleryOption: [(any ReadGalleryOptional)?]] = [
            .galleries: [],
            .master: [],
            .searchToken: []
        ]
        
        let searchTokenTitle = SQLite.Expression<String?>(
            searchToken.titleColumn.template.droppingQuotes()
        )
                
        try dbConnection.prepare(findGalleriesQuery).forEach { row in
            let theGallery = SerializedGalleryModel(row, namespaceColumns: true)
            result[.galleries]?.append(theGallery)
        
            if options.contains(.searchToken) {
                if let searchTokenTitle = row[searchToken.table[searchTokenTitle]] {
                    result[.searchToken]?.append(
                        SerializedSearchTokenModel(
                            title: searchTokenTitle,
                            icon: row[searchToken.table[searchToken.iconColumn]],
                            iconColorHex: row[searchToken.table[searchToken.iconColorHexColumn]],
                            gallery: row[gallery.table[gallery.nameColumn]],
                            tool: row[gallery.table[gallery.foreignKeys.toolColumn]],
                            tab: row[gallery.table[gallery.foreignKeys.tabColumn]],
                            map: row[gallery.table[gallery.foreignKeys.mapColumn]],
                            game: row[gallery.table[gallery.foreignKeys.gameColumn]]
                        )
                    )
                } else {
                    result[.searchToken]?.append(nil)
                }
            }
            
            if options.contains(.master) {
                result[.master]?.append(
                    row[masterSlavesGalleriesView[SQLite.Expression<String?>("master")]]
                )
            }
            
        }
        
        return result
    }
    

    // MARK: - GALLERIES
    public static func readSearchToken(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> SerializedSearchTokenModel? {
        let searchToken = DBMS.gallerySearchToken
        
        let findSearchToken = searchToken.table.filter(
                searchToken.foreignKeys.gameColumn == game &&
                searchToken.foreignKeys.mapColumn == map &&
                searchToken.foreignKeys.tabColumn == tab &&
                searchToken.foreignKeys.toolColumn == tool &&
                searchToken.foreignKeys.galleryColumn == gallery
            )
        
        
        let tokens = try dbConnection.prepare(findSearchToken).map { result in
            return SerializedSearchTokenModel(result)
        }
        
        assert(tokens.count <= 1)
        
        if let theToken = tokens.first {
            return theToken
        } else {
            return nil
        }
    }
    
    
    // FIXME: Add support for new ReadGalleryOption .master
    /// Returns from database the set of all the top level `master`s for the specified gallery, along with the requested optionals.
    ///
    /// - Optionals:
    ///     - **galleries**: This is always included. The images models are always included regardless of whether or not you explicitly include this option. Also,
    ///     the associated array never contains optionals, so it's safe to cast to `[SerializedGalleryModel]`
    ///     - **searchTokens**: If included, all the search tokens for the loaded galleries will be included here. If this option is specified, the `.searchToken` key for the result will have a non-nil value,
    ///     but such value might be an empty array if no search token was specified for any of the galleries.
    ///     - **imagesCount:** The number of images directly associated with the specified gallery.
    ///     - **master:** The id of the master of the specified image if exists, nil otherwise.
    ///     - **subgalleriesCount:** The number slaves galleries for the specified gallery.
    ///     - **nestedLevel:** The depth at which the specified gallery appears in the galleries graph.
    ///     - **maxDepth:** The maximum depth of a gallery for this tool. Returned as an array of a single element
    ///
    /// The association between a gallery and its outline, bounding circle, label and so on, is by foreign key. In general, a gallery and a token that occupy the same index in the output arrays won't be associated
    /// with one another.
    public static func readFirstLevelOfGalleriesForTool(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        options: Set<ReadGalleryOption> = Set<ReadGalleryOption>([.searchToken])
    ) throws -> [ReadGalleryOption: [(any ReadGalleryOptional)?]] {
        var galleriesWithOptions: [ReadGalleryOption: [(any ReadGalleryOptional)?]] = [:]
        
        let galleries = try self.readFirstLevelOfGalleriesForTool(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool
        )
        
        galleriesWithOptions[.galleries] = galleries
        
        if options.contains(.searchToken) {
            var allTokens: [SerializedSearchTokenModel] = []
            
            try galleries.forEach { gallery in
                let theToken = try self.readSearchToken(
                    for: dbConnection,
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool,
                    gallery: gallery.getName()
                )
                
                if let token = theToken {
                    allTokens.append(token)
                }
            }
            
            galleriesWithOptions[.searchToken] = allTokens
        }
        
        if options.contains(.master) {
            galleriesWithOptions[.master] = .init(repeating: nil, count: galleries.count)
        }

        if options.contains(.imagesCount) {
            var imagesCounts: [Int] = .init(repeating: 0, count: galleries.count)
            
            for (index, gallery) in galleries.enumerated() {
                imagesCounts[index] = try DBMS.CRUD.countImagesForGallery(
                    includeVariants: false,
                    for: dbConnection,
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool,
                    gallery: gallery.getName()
                )
            }
            
            galleriesWithOptions[.imagesCount] = imagesCounts
        }
        
        if options.contains(.subgalleriesCount) {
            var subgalleriesCount: [Int] = .init(repeating: 0, count: galleries.count)
            
            for (index, gallery) in galleries.enumerated() {
                subgalleriesCount[index] = try DBMS.CRUD.countSubgalleriesForGallery(
                    for: dbConnection,
                    master: gallery.getName(),
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool
                )
            }

            galleriesWithOptions[.subgalleriesCount] = subgalleriesCount
        }
        
        if options.contains(.nestingLevel) {
            galleriesWithOptions[.nestingLevel] = .init(repeating: 0, count: galleries.count)
        }
        
        if options.contains(.maxDepth) {
            let maxDepth = try Self.readMaxDepthOfGalleryForTool(
                for: dbConnection,
                game: game,
                map: map,
                tab: tab,
                tool: tool,
            )
            
            galleriesWithOptions[.maxDepth] = [maxDepth]
        }
        
        return galleriesWithOptions
    }
    
    
    
    private static func readFirstLevelOfSubgalleriesForGallery(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        master: String
    ) throws -> [SerializedGalleryModel] {
        let gallery = DBMS.gallery
        let subgallery = DBMS.subgallery
        
        let findSlavesQuery = subgallery.table
            .select(subgallery.slaveColumn)
            .filter(
                subgallery.foreignKeys.gameColumn == game &&
                subgallery.foreignKeys.mapColumn == map &&
                subgallery.foreignKeys.tabColumn == tab &&
                subgallery.foreignKeys.toolColumn == tool &&
                subgallery.masterColumn == master
            )
        
        let slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[subgallery.slaveColumn]
        }
        
        let firstLevelMastersQuery = gallery.table.filter(
            gallery.foreignKeys.gameColumn == game &&
            gallery.foreignKeys.mapColumn == map &&
            gallery.foreignKeys.tabColumn == tab &&
            gallery.foreignKeys.toolColumn == tool &&
            slaves.contains(gallery.nameColumn)
        )
        .order(gallery.positionColumn)
        
        return try dbConnection.prepare(firstLevelMastersQuery).map { galleryRow in
            return SerializedGalleryModel(galleryRow)
        }
    }
    
    // FIXME: Add support for new ReadGalleryOption .master
    /// Returns from database the set of all the top level `master`s for the specified gallery, along with the requested optionals.
    ///
    /// - Optionals:
    ///     - **galleries**: This is always included. The images models are always included regardless of whether or not you explicitly include this option. Also,
    ///     the associated array never contains optionals, so it's safe to cast to `[SerializedGalleryModel]`
    ///     - **searchTokens**: If included, all the search tokens for the loaded galleries will be included here. If this option is specified, the `.searchToken` key for the result will have a non-nil value,
    ///     but such value might be an empty array if no search token was specified for any of the galleries.
    ///
    ///
    /// The association between a gallery and its outline, bounding circle, label and so on, is by foreign key. In general, a gallery and a token that occupy the same index in the output arrays won't be associated
    /// with one another.
    public static func readFirstLevelOfSubgalleriesForGallery(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
        options: Set<ReadGalleryOption> = Set<ReadGalleryOption>([.searchToken])
    ) throws -> [ReadGalleryOption: [(any ReadGalleryOptional)?]] {
        var galleriesWithOptions: [ReadGalleryOption: [(any ReadGalleryOptional)?]] = [:]
        
        let galleries = try self.readFirstLevelOfSubgalleriesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            master: gallery
        )
        
        galleriesWithOptions[.galleries] = galleries
        
        if options.contains(.searchToken) {
            var allTokens: [SerializedSearchTokenModel] = []
            
            try galleries.forEach { gallery in
                let theToken = try self.readSearchToken(
                    for: dbConnection,
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool,
                    gallery: gallery.getName()
                )
                
                if let token = theToken {
                    allTokens.append(token)
                }
            }
            
            galleriesWithOptions[.searchToken] = allTokens
        }
        
        if options.contains(.master) {
            let findGallery = DBMS.gallery.table
                .filter(
                    DBMS.gallery.foreignKeys.gameColumn == game &&
                    DBMS.gallery.foreignKeys.mapColumn == map &&
                    DBMS.gallery.foreignKeys.tabColumn == tab &&
                    DBMS.gallery.foreignKeys.toolColumn == tool &&
                    DBMS.gallery.nameColumn == gallery
                )
            
            let thisGallery = try dbConnection.prepare(findGallery).map { galleryRow in
                return SerializedGalleryModel(galleryRow)
            }
            
            assert(thisGallery.count == 1)
            
            galleriesWithOptions[.master] = .init(repeating: thisGallery.first, count: galleries.count)
        }
        
        
        if options.contains(.imagesCount) {
            var imagesCounts: [Int] = .init(repeating: 0, count: galleries.count)
            
            for (index, gallery) in galleries.enumerated() {
                imagesCounts[index] = try DBMS.CRUD.countImagesForGallery(
                    includeVariants: false,
                    for: dbConnection,
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool,
                    gallery: gallery.getName()
                )
            }
            
            galleriesWithOptions[.imagesCount] = imagesCounts
        }
        
        if options.contains(.subgalleriesCount) {
            var subgalleriesCount: [Int] = .init(repeating: 0, count: galleries.count)
            
            for (index, gallery) in galleries.enumerated() {
                subgalleriesCount[index] = try DBMS.CRUD.countSubgalleriesForGallery(
                    for: dbConnection,
                    master: gallery.getName(),
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool
                )
            }

            galleriesWithOptions[.subgalleriesCount] = subgalleriesCount
        }
        
        if options.contains(.maxDepth) {
            var maxDepths: [Int?] = .init(repeating: 0, count: galleries.count)
            
            for (index, gallery) in galleries.enumerated() {
                maxDepths[index] = try DBMS.CRUD.readMaxDepthOfSubgalleryRootedInGallery(
                    for: dbConnection,
                    master: gallery.getName(),
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool
                )
            }

            
            galleriesWithOptions[.subgalleriesCount] = maxDepths
        }
        
        if options.contains(.nestingLevel) {
            var nestingLevels: [Int] = .init(repeating: 0, count: galleries.count)
            
            for (index, gallery) in galleries.enumerated() {
                nestingLevels[index] = try DBMS.CRUD.readGalleryNestingDepth(
                    for: dbConnection,
                    game: game,
                    map: map,
                    tab: tab,
                    tool: tool,
                    gallery: gallery.getName(),
                ) ?? 0
            }
            
            galleriesWithOptions[.nestingLevel] = nestingLevels
        }

        
        return galleriesWithOptions
    }
    
    
    // MARK: - TAB
    
    /// - `TAB(name, position, iconName, map, game)`
    public static func readTabsForMap(
        for dbConnection: Connection,
        game: String,
        map: String
    ) throws -> [SerializedTabModel] {
        let tabs = DBMS.tab
        
        let findTabsQuery = tabs.table
            .filter(
                tabs.foreignKeys.gameColumn == game &&
                tabs.foreignKeys.mapColumn == map
            ).order(tabs.positionColumn)
        
        return try dbConnection.prepare(findTabsQuery).map { result in
            return SerializedTabModel(result)
        }
    }
    
    
    public static func readTabsWithToolsForMap(
        for dbConnection: Connection,
        game: String,
        map: String
    ) throws -> [SerializedTabModelWithTools] {
        let tabs = try Self.readTabsForMap(for: dbConnection, game: game, map: map)
        
        return try tabs.map { tab in
            let tools = try Self.readToolsForTab(for: dbConnection, game: game, map: map, tab: tab.getName())
            return SerializedTabModelWithTools(tabModel: tab, tools: tools)
        }
    }
    
    
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func readTabPosition(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
    ) throws -> Int? {
        let tabTable = DBMS.tab
        
        let findToolQuery = tabTable.table.filter(
            tabTable.nameColumn == tab.lowercased() &&
            tabTable.foreignKeys.gameColumn == game.lowercased() &&
            tabTable.foreignKeys.mapColumn == map.lowercased()
        )
        
        let positions = try dbConnection.prepare(findToolQuery).map { result in
            return result[tabTable.positionColumn]
        }
        
        assert(positions.count <= 1)
        
        return positions.first
    }
    
    
    
    public static func readGalleryNestingDepth(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
    ) throws -> Int? {
        let galleryTable = DBMS.gallery
        let slavesTable = DBMS.subgallery
        
        let query: String = """
        WITH RECURSIVE GALLERY_SLAVES AS (
            SELECT
                \(galleryTable.tableName).\(galleryTable.nameColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template),
                0 AS depth
            FROM \(galleryTable.tableName)
            WHERE \(galleryTable.tableName).\(galleryTable.nameColumn.template) = "\(gallery)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template) = "\(tool)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template) = "\(tab)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template) = "\(map)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template) = "\(game)"

            UNION ALL

            SELECT
                GALLERY_MASTERS.\(galleryTable.nameColumn.template),
                GALLERY_MASTERS.\(galleryTable.foreignKeys.toolColumn.template),
                GALLERY_MASTERS.\(galleryTable.foreignKeys.tabColumn.template),
                GALLERY_MASTERS.\(galleryTable.foreignKeys.mapColumn.template),
                GALLERY_MASTERS.\(galleryTable.foreignKeys.gameColumn.template),
                GALLERY_SLAVES.depth + 1
            FROM GALLERY_SLAVES
            JOIN \(slavesTable.tableName)
              ON \(slavesTable.tableName).\(slavesTable.slaveColumn.template) = GALLERY_SLAVES.\(galleryTable.nameColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template) = GALLERY_SLAVES.\(galleryTable.foreignKeys.toolColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template) = GALLERY_SLAVES.\(galleryTable.foreignKeys.tabColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template) = GALLERY_SLAVES.\(galleryTable.foreignKeys.mapColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template) = GALLERY_SLAVES.\(galleryTable.foreignKeys.gameColumn.template)
            JOIN \(galleryTable.tableName) GALLERY_MASTERS
              ON GALLERY_MASTERS.\(galleryTable.nameColumn.template) = \(slavesTable.tableName).\(slavesTable.masterColumn.template)
             AND GALLERY_MASTERS.\(galleryTable.foreignKeys.toolColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template)
             AND GALLERY_MASTERS.\(galleryTable.foreignKeys.tabColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template)
             AND GALLERY_MASTERS.\(galleryTable.foreignKeys.mapColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template)
             AND GALLERY_MASTERS.\(galleryTable.foreignKeys.gameColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template)
        )
        
        
        SELECT MAX(depth) AS gallery_depth
        FROM GALLERY_SLAVES;
        """
        
        var statement: OpaquePointer?
        
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_prepare_v2(dbConnection.handle, query, -1, &statement, nil) == SQLITE_OK {
            var depths: [Int] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                if sqlite3_column_type(statement, 0) == SQLITE_NULL {
                    return nil
                } else {
                    let depth = sqlite3_column_int(statement, 0)
                    depths.append(Int(depth))
                }
            }
            
            assert(depths.count == 1)
            return depths.first
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection.handle))
            throw SQLQueryError.genericError(reason: errorMessage)
        }
        
    }
    
    
    public static func readMaxDepthOfGalleryForTool(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Int? {
        let galleryTable = DBMS.gallery
        let slavesTable = DBMS.subgallery
        
        let maxDepthQuery: String = """
        WITH RECURSIVE GalleryDepth(\(galleryTable.nameColumn.template), \(galleryTable.foreignKeys.toolColumn.template), \(galleryTable.foreignKeys.tabColumn.template), \(galleryTable.foreignKeys.mapColumn.template), \((galleryTable.foreignKeys.gameColumn.template)), depth) AS (
            SELECT \(galleryTable.tableName).\(galleryTable.nameColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template),
                   CASE
                       WHEN (SELECT COUNT(*) 
                             FROM \(galleryTable.tableName) g2
                             WHERE g2.\(galleryTable.foreignKeys.toolColumn.template) = \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template)
                               AND g2.\(galleryTable.foreignKeys.tabColumn.template) = \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template)
                               AND g2.\(galleryTable.foreignKeys.mapColumn.template) = \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template)
                               AND g2.\(galleryTable.foreignKeys.gameColumn.template) = \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template)
                            ) = 1
                       THEN 0
                       ELSE 1
                   END AS depth
            FROM \(galleryTable.tableName)
            WHERE \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template) = "\(tool)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template)  = "\(tab)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template)  = "\(map)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template)  = "\(game)"

            UNION ALL

            SELECT child.\(galleryTable.nameColumn.template), child.\(galleryTable.foreignKeys.toolColumn.template), child.\(galleryTable.foreignKeys.tabColumn.template), child.\(galleryTable.foreignKeys.mapColumn.template), child.\(galleryTable.foreignKeys.gameColumn.template), gd.depth + 1
            FROM GalleryDepth gd
            JOIN \(slavesTable.tableName)
              ON \(slavesTable.tableName).\(slavesTable.masterColumn.template) = gd.\(galleryTable.nameColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template) = gd.\(galleryTable.foreignKeys.toolColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template) = gd.\(galleryTable.foreignKeys.tabColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template) = gd.\(galleryTable.foreignKeys.mapColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template) = gd.\(galleryTable.foreignKeys.gameColumn.template)
            JOIN \(galleryTable.tableName) child
              ON child.\(galleryTable.nameColumn.template) = \(slavesTable.tableName).\(slavesTable.slaveColumn.template)
             AND child.\(galleryTable.foreignKeys.toolColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template)
             AND child.\(galleryTable.foreignKeys.tabColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template)
             AND child.\(galleryTable.foreignKeys.mapColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template)
             AND child.\(galleryTable.foreignKeys.gameColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template)
        )
        SELECT MAX(depth) AS max_depth
        FROM GalleryDepth;
        """
        
        var statement: OpaquePointer?
        
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_prepare_v2(dbConnection.handle, maxDepthQuery, -1, &statement, nil) == SQLITE_OK {
            var depths: [Int] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                if sqlite3_column_type(statement, 0) == SQLITE_NULL {
                    return nil
                } else {
                    let depth = sqlite3_column_int(statement, 0)
                    depths.append(Int(depth))
                }
            }
            
            assert(depths.count == 1)
            return depths.first
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection.handle))
            throw SQLQueryError.genericError(reason: errorMessage)
        }
        
    }
    
    /// Returns the depth of a tree with root in the specified master gallery. It returns
    public static func readMaxDepthOfSubgalleryRootedInGallery(
        for dbConnection: Connection,
        master: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
    ) throws -> Int? {
        let galleryTable = DBMS.gallery
        let slavesTable = DBMS.subgallery
        
        let maxDepthQuery: String = """
        WITH RECURSIVE GalleryDepth(\(galleryTable.nameColumn), \(galleryTable.foreignKeys.toolColumn.template), \(galleryTable.foreignKeys.tabColumn.template), \(galleryTable.foreignKeys.mapColumn.template), \(galleryTable.foreignKeys.gameColumn.template), depth) AS (
            SELECT \(galleryTable.tableName).\(galleryTable.nameColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template), \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template),
                   0 AS depth
            FROM GALLERY
            WHERE \(galleryTable.tableName).\(galleryTable.nameColumn.template) = "\(master)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template) = "\(tool)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template) = "\(tab)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template) = "\(map)"
              AND \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template) =  "\(game)"

            UNION ALL

            SELECT child.\(galleryTable.nameColumn.template), child.\(galleryTable.foreignKeys.toolColumn.template), child.\(galleryTable.foreignKeys.tabColumn.template), child.\(galleryTable.foreignKeys.mapColumn.template), child.\(galleryTable.foreignKeys.gameColumn.template), gd.depth + 1
            FROM GalleryDepth gd
            JOIN \(slavesTable.tableName)
              ON \(slavesTable.tableName).\(slavesTable.masterColumn.template) = gd.\(galleryTable.nameColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template) = gd.\(galleryTable.foreignKeys.toolColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template) = gd.\(galleryTable.foreignKeys.tabColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template) = gd.\(galleryTable.foreignKeys.mapColumn.template)
             AND \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template) = gd.\(galleryTable.foreignKeys.gameColumn.template)
            JOIN \(galleryTable.tableName) child
              ON child.\(galleryTable.nameColumn.template) = \(slavesTable.tableName).\(slavesTable.slaveColumn.template)
             AND child.\(galleryTable.foreignKeys.toolColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template)
             AND child.\(galleryTable.foreignKeys.tabColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template)
             AND child.\(galleryTable.foreignKeys.mapColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template)
             AND child.\(galleryTable.foreignKeys.gameColumn.template) = \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template)
        )
        SELECT MAX(depth) AS max_depth
        FROM GalleryDepth;
        """
        
        var statement: OpaquePointer?
        
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_prepare_v2(dbConnection.handle, maxDepthQuery, -1, &statement, nil) == SQLITE_OK {
            var depths: [Int] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                if sqlite3_column_type(statement, 0) == SQLITE_NULL {
                    return nil
                } else {
                    let depth = sqlite3_column_int(statement, 0)
                    depths.append(Int(depth))
                }
            }
            
            assert(depths.count == 1)
            return depths.first
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection.handle))
            throw SQLQueryError.genericError(reason: errorMessage)
        }
    }
    
    
    /// Returns a flat list of the subtree of all the galleries with root in the specified master
    ///
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func readSubgalleryTree(
        for dbConnection: Connection,
        master: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
    ) throws -> [SerializedGalleryModel] {
        let galleryTable = DBMS.gallery
        let slavesTable = DBMS.subgallery
        
        let findAllSubgalleriesQuery: String = """
        WITH RECURSIVE SubtreeOfGallery AS (
            SELECT
                \(galleryTable.tableName).\(galleryTable.nameColumn.template),
                \(galleryTable.tableName).\(galleryTable.positionColumn.template),
                \(galleryTable.tableName).\(galleryTable.assetsImageNameColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template),
                \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template)
            FROM \(galleryTable.tableName)
            WHERE
                \(galleryTable.tableName).\(galleryTable.nameColumn.template) = "\(master.lowercased())"
                AND \(galleryTable.tableName).\(galleryTable.foreignKeys.toolColumn.template) = "\(tool.lowercased())"
                AND \(galleryTable.tableName).\(galleryTable.foreignKeys.tabColumn.template) = "\(tab.lowercased())"
                AND \(galleryTable.tableName).\(galleryTable.foreignKeys.mapColumn.template) = "\(map.lowercased())"
                AND \(galleryTable.tableName).\(galleryTable.foreignKeys.gameColumn.template) = "\(game.lowercased())"

            UNION ALL

            SELECT
                SUBGALLERY.\(galleryTable.nameColumn.template),
                SUBGALLERY.\(galleryTable.positionColumn.template),
                SUBGALLERY.\(galleryTable.assetsImageNameColumn.template),
                SUBGALLERY.\(galleryTable.foreignKeys.toolColumn.template),
                SUBGALLERY.\(galleryTable.foreignKeys.tabColumn.template),
                SUBGALLERY.\(galleryTable.foreignKeys.mapColumn.template),
                SUBGALLERY.\(galleryTable.foreignKeys.gameColumn.template)
            FROM
                \(galleryTable.tableName) SUBGALLERY
            INNER JOIN \(slavesTable.tableName) ON
                \(slavesTable.tableName).\(slavesTable.slaveColumn.template) = SUBGALLERY.\(galleryTable.nameColumn.template)
                AND \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template) = SUBGALLERY.\(galleryTable.foreignKeys.toolColumn.template)
                AND \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template) = SUBGALLERY.\(galleryTable.foreignKeys.tabColumn.template)
                AND \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template) = SUBGALLERY.\(galleryTable.foreignKeys.mapColumn.template)
                AND \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template) = SUBGALLERY.\(galleryTable.foreignKeys.gameColumn.template)
            INNER JOIN SubtreeOfGallery ON 
                SubtreeOfGallery.\(galleryTable.nameColumn.template
        ) = \(slavesTable.tableName).\(slavesTable.masterColumn.template)
                AND SubtreeOfGallery.\(galleryTable.foreignKeys.toolColumn) = \(slavesTable.tableName).\(slavesTable.foreignKeys.toolColumn.template)
                AND SubtreeOfGallery.\(galleryTable.foreignKeys.tabColumn) = \(slavesTable.tableName).\(slavesTable.foreignKeys.tabColumn.template)
                AND SubtreeOfGallery.\(galleryTable.foreignKeys.mapColumn) = \(slavesTable.tableName).\(slavesTable.foreignKeys.mapColumn.template)
                AND SubtreeOfGallery.\(galleryTable.foreignKeys.gameColumn) = \(slavesTable.tableName).\(slavesTable.foreignKeys.gameColumn.template)
        )
        SELECT * FROM SubtreeOfGallery;
        """
        
        var statement: OpaquePointer?
        
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_prepare_v2(dbConnection.handle, findAllSubgalleriesQuery, -1, &statement, nil) == SQLITE_OK {
            var subgalleries: [SerializedGalleryModel] = []
            
            while sqlite3_step(statement) == SQLITE_ROW {
                /*
                 Column 0: name String
                 Column 1: position Int
                 Column 2: assetsImageName: String?
                 Column 3: tool: String
                 Column 4: tab: String
                 Column 5: map: String
                 Column 6: game: String
                 */
                
                let nameColumn = String(cString: sqlite3_column_text(statement, 0))
                let positionColumn = sqlite3_column_int(statement, 1)
                let assetsImageNameColumn = sqlite3_column_type(statement, 2) != SQLITE_NULL ? String(cString: sqlite3_column_text(statement,2)) : nil
                let toolColumn = String(cString: sqlite3_column_text(statement, 3))
                let tabColumn = String(cString: sqlite3_column_text(statement, 4))
                let mapColumn = String(cString: sqlite3_column_text(statement, 5))
                let gameColumn = String(cString: sqlite3_column_text(statement, 6))
                
                subgalleries.append(SerializedGalleryModel(
                    name: nameColumn,
                    position: Int(positionColumn),
                    assetsImageName: assetsImageNameColumn,
                    tool: toolColumn,
                    tab: tabColumn,
                    map: mapColumn,
                    game: gameColumn
                ))
            }
            
            return subgalleries
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbConnection.handle))
            throw SQLQueryError.genericError(reason: errorMessage)
        }
    }
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func readGalleryPosition(
        for dbConnection: Connection,
        gallery: String,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Int? {
        let findImageQuery = DBMS.gallery
        
        let findGalleryQuery = findImageQuery.table.filter(
            findImageQuery.nameColumn == gallery.lowercased() &&
            findImageQuery.foreignKeys.gameColumn == game.lowercased() &&
            findImageQuery.foreignKeys.mapColumn == map.lowercased() &&
            findImageQuery.foreignKeys.tabColumn == tab.lowercased() &&
            findImageQuery.foreignKeys.toolColumn == tool.lowercased()
        )
        
        
        let positions = try dbConnection.prepare(findGalleryQuery).map { result in
            return result[findImageQuery.positionColumn]
        }
        
        assert(positions.count <= 1)
        
        return positions.first
    }
    
    /// - `GALLERY(name, position, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func readMasterForGallery(
        for dbConnection: Connection,
        gallery: String,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> SerializedGalleryModel? {
        let slavesTable = DBMS.subgallery
        let galleryTable = DBMS.gallery
        
        let findMasterQuery = galleryTable.table
            .select(
                galleryTable.nameColumn,
                galleryTable.assetsImageNameColumn,
                galleryTable.positionColumn,
                galleryTable.foreignKeys.gameColumn,
                galleryTable.foreignKeys.mapColumn,
                galleryTable.foreignKeys.tabColumn,
                galleryTable.foreignKeys.toolColumn,
            )
            .join(
                slavesTable.table,
                on: slavesTable.slaveColumn == gallery &&
                slavesTable.masterColumn == galleryTable.nameColumn &&
                slavesTable.foreignKeys.gameColumn == galleryTable.foreignKeys.gameColumn &&
                slavesTable.foreignKeys.mapColumn == galleryTable.foreignKeys.mapColumn &&
                slavesTable.foreignKeys.tabColumn == galleryTable.foreignKeys.tabColumn &&
                slavesTable.foreignKeys.toolColumn == galleryTable.foreignKeys.toolColumn
        )
        
        let masters = try dbConnection.prepare(findMasterQuery).map { result in
            return SerializedGalleryModel(result)
        }

        assert(masters.count <= 0)
        return masters.first
    }
    
    // MARK: - TOOLS
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func readToolsForTab(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String
    ) throws -> [SerializedToolModel] {
        let tools = DBMS.tool
        
        let findToolsQuery = tools.table
            .filter(
                tools.foreignKeys.gameColumn == game &&
                tools.foreignKeys.mapColumn == map &&
                tools.foreignKeys.tabColumn == tab
            ).order(tools.positionColumn)
        
        return try dbConnection.prepare(findToolsQuery).map { result in
            return SerializedToolModel(result)
        }
    }
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func readToolPosition(
        for dbConnection: Connection,
        tool: String,
        game: String,
        map: String,
        tab: String,
    ) throws -> Int? {
        let toolTable = DBMS.tool
        
        let findToolQuery = toolTable.table.filter(
            toolTable.nameColumn == tool.lowercased() &&
            toolTable.foreignKeys.gameColumn == game.lowercased() &&
            toolTable.foreignKeys.mapColumn == map.lowercased() &&
            toolTable.foreignKeys.tabColumn == tab.lowercased()
        )
        
        let positions = try dbConnection.prepare(findToolQuery).map { result in
            return result[toolTable.positionColumn]
        }
        
        assert(positions.count <= 1)
        
        return positions.first
    }
    
    
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    internal static func readTabForTool(
        for dbConnection: Connection,
        tool: String,
        game: String,
        map: String,
    ) throws -> SerializedTabModel? {
        let toolTable = DBMS.tool
        
        let findTabQuery = toolTable.table.filter(
            toolTable.nameColumn == tool.lowercased() &&
            toolTable.foreignKeys.gameColumn == game.lowercased() &&
            toolTable.foreignKeys.mapColumn == map.lowercased()
        )
        
        let tabs = try dbConnection.prepare(findTabQuery).map { result in
            return SerializedTabModel(result)
        }
        
        assert(tabs.count <= 1)
        
        return tabs.first
    }
}




public enum ReadGamesOption: Sendable {
    case games
    case numberOfMaps
}

public enum ReadMapOptions: Sendable {
    case maps
    case numberOfSlaves
    case numberOfTabs
    case numberOfTools
}


public enum ReadImageOption: Sendable {
    case medias
    case outlines
    case boundingCircles
    case labels
    case variantsMetadatas
    case masters
}

public enum ReadGalleryOption: Sendable {
    case galleries
    case searchToken
    case master
    case imagesCount
    case subgalleriesCount
    case nestingLevel
    case maxDepth
}


extension Set where Element == ReadImageOption {
    public static let all = Set<Element>([
        .medias, .outlines, .boundingCircles, .labels, .variantsMetadatas
    ])
}


extension Set where Element == ReadGamesOption {
    public static let all = Set<Element>([
        .games, .numberOfMaps
    ])
}

extension Set where Element == ReadMapOptions {
    public static let all = Set<Element>([
        .maps, .numberOfSlaves, .numberOfTabs, .numberOfTools
    ])
}


extension Int: ReadGameOptional, ReadMapOptional, ReadGalleryOptional {
    
}
