import Foundation
import SQLite

internal extension CRUD {
    // MARK: - RANDOM GAME
    static func randomGame(for connection: Connection) throws -> SerializedGameModel {
        let gamesCount = try CRUD.countGames(for: connection)
        let randomIndex = Int.random(in: 0..<gamesCount)
        
        let gameQuery = DBMS.game.table.filter(DBMS.game.positionColumn == randomIndex).limit(1)
        
        guard let randomGameRow = try connection.pluck(gameQuery) else {
            fatalError("Unable to fetch row for game in position \(randomIndex). Aborting.")
        }
        
        return SerializedGameModel(randomGameRow)
    }
    
    
    // MARK: - RANDOM MAP
    static func randomMap(
        for connection: Connection,
        game: String? = nil
    ) throws -> SerializedMapModel {
        
        func fetchMap(game: String, position: Int) throws -> SerializedMapModel {
            let randomMapQuery = DBMS.map.table.filter(
                DBMS.map.positionColumn == position &&
                DBMS.map.foreignKeys.gameColumn == game
            )
            
            guard let randomMap = try connection.pluck(randomMapQuery) else {
                fatalError("Unable to fetch map for position \(position) in game \(game). Aborting.")
            }
            
            return SerializedMapModel(randomMap)
        }
        
        
        if let game = game {
            let mapsCountForGame = try CRUD.countMapsForGame(for: connection, game: game)
            guard mapsCountForGame > 0 else {
                fatalError("The specified game does not have any maps. Aborting.")
            }
            
            let randomMapIndex = Int.random(in: 0..<mapsCountForGame)
            return try fetchMap(game: game, position: randomMapIndex)
        } else {
            var game: SerializedGameModel
            var mapsCountForGame: Int
            
            repeat {
                game = try CRUD.randomGame(for: connection)
                mapsCountForGame = try CRUD.countMapsForGame(for: connection, game: game.getName())
                
                if mapsCountForGame > 0 {
                    break
                }
            } while(true)
            
            let randomMapIndex = Int.random(in: 0..<mapsCountForGame)
            return try fetchMap(game: game.getName(), position: randomMapIndex)
        }
    }
    
    // MARK: RANDOM TAB
    static func randomTab(
        for connection: Connection,
        map: String? = nil,
        game: String? = nil
    ) throws -> SerializedTabModel {
        assert(game == nil && map == nil || game != nil && map != nil, "At the moment, you either specify both game and map, or none.")
        
        func fetchTab(game: String, map: String, position: Int) throws -> SerializedTabModel {
            let query = DBMS.tab.table.filter(
                DBMS.tab.positionColumn == position &&
                DBMS.tab.foreignKeys.mapColumn == map &&
                DBMS.tab.foreignKeys.gameColumn == game
            )
            
            guard let tabRow = try connection.pluck(query) else {
                fatalError("Failed to fetch tab at position \(position) for \(game)/\(map)")
            }
            
            return SerializedTabModel(tabRow)
        }
        
        if let game = game, let map = map {
            let tabsCount = try CRUD.countTabsForMap(
                for: connection,
                map: map,
                game: game
            )
            
            let randomTabIndex = Int.random(in: 0..<tabsCount)
            return try fetchTab(game: game, map: map, position: randomTabIndex)
        } else {
            let randomMap = try CRUD.randomMap(for: connection)
            let tabsCount = try CRUD.countTabsForMap(
                for: connection,
                map: randomMap.getName(),
                game: randomMap.getGame()
            )

            let randomIndex = Int.random(in: 0..<tabsCount)
            return try fetchTab(game: randomMap.getGame(), map: randomMap.getName(), position: randomIndex)
        }
    }
    
    // MARK: - RANDOM TOOL
    static func randomTool(
        for connection: Connection,
        tab: String? = nil,
        map: String? = nil,
        game: String? = nil
    ) throws -> SerializedToolModel {
        assert(
            tab == nil && game == nil && map == nil ||
            tab != nil && game != nil && map != nil, "At the moment, you either completely specify (tab, game, map), or none."
        )
        
        func fetchTool(
            tab: String,
            map: String,
            game: String,
            position: Int
        ) throws -> SerializedToolModel {
            let query = DBMS.tool.table.filter(
                DBMS.tool.positionColumn == position &&
                DBMS.tool.foreignKeys.tabColumn == tab &&
                DBMS.tool.foreignKeys.mapColumn == map &&
                DBMS.tool.foreignKeys.gameColumn == game
            )
            
            guard let toolRow = try connection.pluck(query) else {
                fatalError("Unable to fetch tool at position \(position) for \(game)/\(map)/\(tab). Aborting.")
            }
            
            return SerializedToolModel(toolRow)
        }
        
        if let tab = tab, let map = map, let game = game {
            let numberOfTools = try CRUD.countToolsForTab(
                for: connection,
                game: game,
                map: map,
                tab: tab
            )
            
            let randomTool = Int.random(in: 0..<numberOfTools)
            return try fetchTool(tab: tab, map: map, game: game, position: randomTool)
        } else {
            var randomTab: SerializedTabModel
            var toolsCount: Int
            
            repeat {
                randomTab = try CRUD.randomTab(for: connection)
                toolsCount = try CRUD.countToolsForTab(
                    for: connection,
                    game: randomTab.getGame(),
                    map: randomTab.getMap(),
                    tab: randomTab.getName()
                )
                
                if toolsCount > 0 {
                    break
                }
            } while(true)
            
            let randomToolIndex = Int.random(in: 0..<toolsCount)
            return try fetchTool(tab: randomTab.getName(), map: randomTab.getMap(), game: randomTab.getGame(), position: randomToolIndex)
        }
    }
    
    
    // MARK: - RANDOM GALLERY
    static func randomGallery(
        for connection: Connection,
        tool: String? = nil,
        tab: String? = nil,
        map: String? = nil,
        game: String? = nil
    ) throws -> SerializedGalleryModel {
        assert(
            tool == nil && tab == nil && game == nil && map == nil ||
            tool != nil && tab != nil && game != nil && map != nil, "At the moment, you either completely specify (tool, tab, game, map), or none."
        )
        
        func fetchGallery(
            tool: String,
            tab: String,
            map: String,
            game: String,
            position: Int
        ) throws -> SerializedGalleryModel {
            let gallery = DBMS.gallery
            let query = gallery.table.filter(
                gallery.positionColumn == position &&
                gallery.foreignKeys.toolColumn == tool &&
                gallery.foreignKeys.tabColumn == tab &&
                gallery.foreignKeys.mapColumn == map &&
                gallery.foreignKeys.gameColumn == game
            )
            
            guard let galleryRow = try connection.pluck(query) else {
                fatalError("Unable to fetch gallery at position \(position) for \(game)/\(map)/\(tool)/\(tab). Aborting.")
            }
            
            return SerializedGalleryModel(galleryRow)
        }
        
        if let tool = tool, let tab = tab, let map = map, let game = game {
            let galleriesCount = try CRUD.countGalleriesForTool(
                for: connection,
                game: game,
                map: map,
                tab: tab,
                tool: tool
            )
            
            guard galleriesCount > 0 else {
                fatalError("\(game)/\(map)/\(tab)/\(tool) has 0 galleries associated with it. Aborting.")
            }
            
            let randomGallery = Int.random(in: 0..<galleriesCount)
            return try fetchGallery(tool: tool, tab: tab, map: map, game: game, position: randomGallery)
        } else {
            var randomTool: SerializedToolModel
            var galleriesCount: Int
            
            repeat {
                randomTool = try CRUD.randomTool(for: connection)
                galleriesCount = try CRUD.countGalleriesForTool(
                    for: connection,
                    game: randomTool.getGame(),
                    map: randomTool.getMap(),
                    tab: randomTool.getTab(),
                    tool: randomTool.getName()
                )
                
                if galleriesCount > 0 {
                    break
                }
            } while(true)
            
            let randomGallery = Int.random(in: 0..<galleriesCount)
            
            return try fetchGallery(
                tool: randomTool.getName(),
                tab: randomTool.getTab(),
                map: randomTool.getMap(),
                game: randomTool.getGame(),
                position: randomGallery
            )
        }
    }
    
    
    // MARK: RANDOM IMAGE
    static func randomImage(
        for connection: Connection,
        gallery: String? = nil,
        tool: String? = nil,
        tab: String? = nil,
        map: String? = nil,
        game: String? = nil
    ) throws -> SerializedImageModel {
        assert(
            gallery == nil && tool == nil && tab == nil && game == nil && map == nil ||
            gallery != nil && tool != nil && tab != nil && game != nil && map != nil, "At the moment, you either completely specify (gallery, tool, tab, game, map), or none."
        )
        
        func fetchImage(
            gallery: String,
            tool: String,
            tab: String,
            map: String,
            game: String,
            position: Int
        ) throws -> SerializedImageModel {
            let image = DBMS.visualMedia
            let query = image.table.filter(
                image.positionColumn == position &&
                image.foreignKeys.galleryColumn == gallery &&
                image.foreignKeys.toolColumn == tool &&
                image.foreignKeys.tabColumn == tab &&
                image.foreignKeys.mapColumn == map &&
                image.foreignKeys.gameColumn == game
            )
            
            guard let imageRow = try connection.pluck(query) else {
                fatalError("Unable to fetch gallery at position \(position) for \(game)/\(map)/\(tool)/\(tab). Aborting.")
            }
            
            return SerializedImageModel(imageRow)
        }
        
        if let gallery = gallery, let tool = tool, let tab = tab, let map = map, let game = game {
            let imagesCount = try CRUD.countImagesForGallery(
                includeVariants: false,
                for: connection,
                game: game,
                map: map,
                tab: tab,
                tool: tool,
                gallery: gallery
            )
            
            guard imagesCount > 0 else {
                fatalError("\(game)/\(map)/\(tab)/\(tool)/\(gallery) has 0 images associated with it. Aborting.")
            }
            
            let randomImage = Int.random(in: 0..<imagesCount)
            return try fetchImage(gallery: gallery, tool: tool, tab: tab, map: map, game: game, position: randomImage)
        } else {
            var randomGallery: SerializedGalleryModel
            var imagesCount: Int
            
            repeat {
                randomGallery = try CRUD.randomGallery(for: connection)
                imagesCount = try CRUD.countImagesForGallery(
                    includeVariants: false,
                    for: connection,
                    game: randomGallery.getGame(),
                    map: randomGallery.getMap(),
                    tab: randomGallery.getTab(),
                    tool: randomGallery.getTool(),
                    gallery: randomGallery.getName()
                )
                
                if imagesCount > 0 {
                    break
                }
            } while(true)
            
            let randomImage = Int.random(in: 0..<imagesCount)
            return try fetchImage(
                gallery: randomGallery.getName(),
                tool: randomGallery.getTool(),
                tab: randomGallery.getTab(),
                map: randomGallery.getMap(),
                game: randomGallery.getGame(),
                position: randomImage
            )
        }
    }
}
