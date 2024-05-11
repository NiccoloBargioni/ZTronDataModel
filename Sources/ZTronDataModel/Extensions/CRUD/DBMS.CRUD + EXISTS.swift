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
    
    // MARK: - IMAGE EXISTS
    /// - `IMAGE(name, description, position, searchLabel, gallery, tool, tab, map, game)`
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
        let imageModel = DBMS.image
        
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
    /// - `FK(slave, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
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
    /// - `FK(image, gallery, tool, tab, map, game) REFERENCES IMAGE(name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
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
}
