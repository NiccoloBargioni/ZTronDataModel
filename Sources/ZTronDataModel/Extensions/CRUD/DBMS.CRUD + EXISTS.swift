import Foundation
import SQLite3
import SQLite

extension DBMS.CRUD {
    // MARK: - GALLERY EXISTS
    /// - `GALLERY(name, assetsImageName, tool, tab, map, game)`
    /// - `PK(name, tool, tab, map, game)`
    /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func galleryExists(
        for dbConnection: Connection,
        gallery: String,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Bool {
        let galleryModel = DBMS.gallery
        
        let countGalleryQuery = galleryModel.table.where(
            galleryModel.nameColumn == gallery &&
            galleryModel.foreignKeys.gameColumn == game &&
            galleryModel.foreignKeys.mapColumn == map &&
            galleryModel.foreignKeys.tabColumn == tab &&
            galleryModel.foreignKeys.toolColumn == tool
        ).count
        
        return try dbConnection.scalar(countGalleryQuery) == 1
    }

    
    internal static func galleryMasterExists(
        for dbConnection: Connection,
        gallery: String,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Bool {
        let subgallery = DBMS.subgallery
        
        let countMastersQuery = subgallery.table.where(
            subgallery.slaveColumn == gallery &&
            subgallery.foreignKeys.gameColumn == game &&
            subgallery.foreignKeys.mapColumn == map &&
            subgallery.foreignKeys.tabColumn == tab &&
            subgallery.foreignKeys.toolColumn == tool
        ).count
        
        return try dbConnection.scalar(countMastersQuery) >= 1

    }
    
    
    /// - `HAS_SUBGALLERY(master, slave, tool, tab, map, game)`
    /// - `PK(slave, tool, tab, map, game)`
    /// - `FK(slave, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func subgalleryRelationshipExists(
        for dbConnection: Connection,
        master: String,
        slave: String,
        game: String,
        map: String,
        tab: String,
        tool: String
    ) throws -> Bool {
        let subgallery = DBMS.subgallery
        
        let countSubgalleryRelationshipQuery = subgallery.table.where(
            subgallery.masterColumn == master &&
            subgallery.slaveColumn == slave &&
            subgallery.foreignKeys.toolColumn == tool &&
            subgallery.foreignKeys.tabColumn == tab &&
            subgallery.foreignKeys.mapColumn == map &&
            subgallery.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countSubgalleryRelationshipQuery) == 1
    }
    
    // - MARK:  SUBMAP RELATIONSHIP EXISTS
    
    /// - `HAS_SUBMAP(master, slave, game)`
    /// - `PK(slave, game)`
    /// - `FK(slave, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func submapRelationshipExists(
        for dbConnection: Connection,
        master: String,
        slave: String,
        game: String
    ) throws -> Bool {
        let submap = DBMS.hasSubmap
        
        let countSubmapsRelationshipQuery = submap.table.where(
            submap.masterColumn == master &&
            submap.slaveColumn == slave &&
            submap.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countSubmapsRelationshipQuery) == 1
    }
    
    // MARK: - SEARCH TOKEN EXISTS
    /// - `GALLERY_SEARCH_TOKEN(title, icon, iconColorHex, gallery, tool, tab, map, game)`
    /// - `PK(gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func gallerySearchTokenExists(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> Bool {
        let searchToken = DBMS.gallerySearchToken
        
        let countSearchTokenQuery = searchToken.table.where(
            searchToken.foreignKeys.galleryColumn == gallery &&
            searchToken.foreignKeys.toolColumn == tool &&
            searchToken.foreignKeys.tabColumn == tab &&
            searchToken.foreignKeys.mapColumn == map &&
            searchToken.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countSearchTokenQuery) == 1
    }
    
    // MARK: - MEDIA EXISTS
    /// - `VISUAL_MEDIA(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
    /// - `PK(name, gallery, tool, tab, map, game)`
    /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
    public static func imageExists(
        for dbConnection: Connection,
        image: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> Bool {
        let imageModel = DBMS.visualMedia
        
        let countImageQuery = imageModel.table.where(
            imageModel.nameColumn == image &&
            imageModel.typeColumn == "image" &&
            imageModel.foreignKeys.galleryColumn == gallery &&
            imageModel.foreignKeys.toolColumn == tool &&
            imageModel.foreignKeys.tabColumn == tab &&
            imageModel.foreignKeys.mapColumn == map &&
            imageModel.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countImageQuery) == 1
    }
    
    public static func videoExists(
        for dbConnection: Connection,
        image: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> Bool {
        let imageModel = DBMS.visualMedia
        
        let countImageQuery = imageModel.table.where(
            imageModel.nameColumn == image &&
            imageModel.typeColumn == "video" &&
            imageModel.foreignKeys.galleryColumn == gallery &&
            imageModel.foreignKeys.toolColumn == tool &&
            imageModel.foreignKeys.tabColumn == tab &&
            imageModel.foreignKeys.mapColumn == map &&
            imageModel.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countImageQuery) == 1
    }

    public static func mediaExists(
        for dbConnection: Connection,
        image: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> Bool {
        let imageModel = DBMS.visualMedia
        
        let countImageQuery = imageModel.table.where(
            imageModel.nameColumn == image &&
            imageModel.foreignKeys.galleryColumn == gallery &&
            imageModel.foreignKeys.toolColumn == tool &&
            imageModel.foreignKeys.tabColumn == tab &&
            imageModel.foreignKeys.mapColumn == map &&
            imageModel.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countImageQuery) == 1
    }

    
    // MARK: - IMAGE VARIANT EXISTS
    /// - `IMAGE_VARIANT(master, slave, variant, bottomBarIcon, boundingFrameOriginX, boundingFrameOriginY, boundingFrameWidth, boundingFrameHeight, gallery, tool, tab, map, game)`
    /// - `PK(slave, gallery, tool, tab, map, game)`
    /// - `FK(slave, gallery, tool, tab, map, game) REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func imageVariantRelationshipExists(
        for dbConnection: Connection,
        master: String,
        slave: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> Bool {
        let imageVariant = DBMS.imageVariant
        
        let countVariantQuery = imageVariant.table.where(
            imageVariant.masterColumn == master &&
            imageVariant.slaveColumn == slave &&
            imageVariant.foreignKeys.galleryColumn == gallery &&
            imageVariant.foreignKeys.toolColumn == tool &&
            imageVariant.foreignKeys.tabColumn == tab &&
            imageVariant.foreignKeys.mapColumn == map &&
            imageVariant.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countVariantQuery) == 1
    }
        
    // MARK: - LABEL EXISTS
    /// - `LABEL(label, isActive, icon, assetsImageName, textColorHex, backgroundColorHex, opacity, maxAABBOriginX, maxAABBOriginY, maxAABBWidth, maxAABBHeight, image, gallery, tool, tab, map, game)`
    /// - `PK(label, image, gallery, tool, tab, map, game)`
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func labelExists(
        for dbConnection: Connection,
        label: String,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String,
        image: String
    ) throws -> Bool {
        let labelModel = DBMS.label
        
        let countLabelQuery = labelModel.table.where(
            labelModel.labelColumn == label &&
            labelModel.foreignKeys.imageColumn == image &&
            labelModel.foreignKeys.galleryColumn == gallery &&
            labelModel.foreignKeys.toolColumn == tool &&
            labelModel.foreignKeys.tabColumn == tab &&
            labelModel.foreignKeys.mapColumn == map &&
            labelModel.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countLabelQuery) == 1
    }
    
    // MARK: Tool Exists
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func toolExists(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String
    ) throws -> Bool {
        let toolModel = DBMS.tool

        let countQuery = toolModel.table.where(
            toolModel.nameColumn == tool &&
            toolModel.foreignKeys.tabColumn == tab &&
            toolModel.foreignKeys.mapColumn == map &&
            toolModel.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countQuery) == 1
    }
    
    
    /// A tool needs migration to a different tab if there exists a (`Tool.name`, `TAB`, `map`, `game`) tuple such that `TAB <> tab`
    /// At some point during the update process it's likely that two (or more, but unlikely) such tuples exist.
    ///
    /// - Note: An assumption is being made that, since the data source is updated with correct indices, the indices update part of the migration will be taken care of later.
    ///
    /// - `TOOL(name, position, assetsImageName, tab, map, game)`
    /// - `PK(name, tab, map, game)`
    /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func toolExistsInDifferentTab(
        for dbConnection: Connection,
        tool: String,
        tab: String,
        map: String,
        game: String,
    ) throws -> Bool {
        let toolModel = DBMS.tool
        
        let allTabsForToolQuery = toolModel.table.filter(
            toolModel.nameColumn == tool &&
            toolModel.foreignKeys.tabColumn != tab &&
            toolModel.foreignKeys.mapColumn == map &&
            toolModel.foreignKeys.gameColumn == game
        )
        
        let tabs = try dbConnection.prepare(allTabsForToolQuery).map { tabRow in
            return SerializedTabModel(tabRow)
        }
        
        return tabs.count > 0
    }
    
    
    // MARK: Tab Exists
    /// - `TAB(name, position, iconName, map, game)`
    /// - `PK(name, map, game)`
    /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func tabExists(
        for dbConnection: Connection,
        tab: String,
        map: String,
        game: String
    ) throws -> Bool {
        let tabModel = DBMS.tab

        let countQuery = tabModel.table.where(
            tabModel.nameColumn == tab &&
            tabModel.foreignKeys.mapColumn == map &&
            tabModel.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countQuery) == 1
    }

    
    
    
    // MARK: Map Exists
    /// - `MAP(name, position, assetsImageName, game)`
    /// - `PK(name, game)`
    /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func mapExists(
        for dbConnection: Connection,
        map: String,
        game: String
    ) throws -> Bool {
        let mapModel = DBMS.map

        let countQuery = mapModel.table.where(
            mapModel.nameColumn == map &&
            mapModel.foreignKeys.gameColumn == game
        ).count
        
        return try dbConnection.scalar(countQuery) == 1
    }
    
    
    // MARK: Game exists
    /// - `GAME(name, position, assetsImageName, studio)`
    /// - `PK(name)`
    /// - `FK(studio) REFERENCES STUDIO(name) ON DELETE CASCADE ON UPDATE CASCADE`
    public static func gameExists(
        for dbConnection: Connection,
        game: String
    ) throws -> Bool {
        let gameModel = DBMS.game

        let countQuery = gameModel.table.where(gameModel.nameColumn == game).count
        
        return try dbConnection.scalar(countQuery) == 1
    }
    
    
    // MARK: Studio exists
    /// - `STUDIO(name, position, assetsImageName)`
    /// - `PK(name)`
    public static func studioExists(
        for dbConnection: Connection,
        studio: String
    ) throws -> Bool {
        let gameModel = DBMS.studio

        let countQuery = gameModel.table.where(gameModel.nameColumn == studio).count
        
        return try dbConnection.scalar(countQuery) == 1
    }

}


public enum OnTabConflictStrategy {
    case keepCurrent
    case removeCurrent
}
