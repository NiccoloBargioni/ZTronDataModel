import Foundation
import SQLite3
import SQLite
import os

extension DBMS {
    public final class CRUD {
        static internal let hexValidatingRegex: NSRegularExpression = {
            do {
                return try NSRegularExpression(pattern: "^#(?:[0-9a-fA-F]{3}){1,2}$")
            } catch {
                fatalError("^#(?:[0-9a-fA-F]{3}){1,2}$ is not a valid regular expression. Aborting")
            }
        }()
        
        internal static let logger: os.Logger = .init(subsystem: "ZTronDataModel", category: "CRUD")

        private init() { }
        
        // MARK: - CREATE
        
        // MARK:  STUDIO
        /// - `STUDIO(name, position, assetsImageName)`
        /// - `PK(name)`
        public static func insertIntoStudio(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            name: String,
            position: Int,
            assetsImageName: String
        ) throws {
            let studio = DBMS.studio
            
            try dbConnection.run(
                studio.table.insert(
                    or: or,
                    studio.nameColumn <- name,
                    studio.positionColumn <- position,
                    studio.assetsImageNameColumn <- assetsImageName
                )
            )
            
        }
        
        // MARK: GAME
        
        /// - `GAME(name, position, assetsImageName, studio)`
        /// - `PK(name)`
        /// - `FK(studio) REFERENCES STUDIO(name) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoGame(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            name: String,
            position: Int,
            assetsImageName: String,
            studio: String
        ) throws {
            let game = DBMS.game
            
            try dbConnection.run(
                game.table.insert(
                    or: or,
                    game.nameColumn <- name,
                    game.positionColumn <- position,
                    game.assetsImageNameColumn <- assetsImageName,
                    game.foreignKeys.studioColumn <- studio
                )
            )
            
        }
        
        // MARK: MAP
        
        /// - `MAP(name, position, assetsImageName, game)`
        /// - `PK(name, game)`
        /// - `FK(game) REFERENCES GAME(name) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoMap(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            name: String,
            position: Int,
            assetsImageName: String,
            game: String
        ) throws {
            let map = DBMS.map
            
            try dbConnection.run(
                map.table.insert(
                    or: or,
                    map.nameColumn <- name,
                    map.positionColumn <- position,
                    map.assetsImageNameColumn <- assetsImageName,
                    map.foreignKeys.gameColumn <- game
                )
            )
            
        }
        
        // MARK: TAB
        
        /// - `TAB(name, position, iconName, map, game)`
        /// - `PK(name, map, game)`
        /// - `FK(map, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoTab(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            name: String,
            position: Int,
            iconName: String,
            game: String,
            map: String
        ) throws {
            let tab = DBMS.tab
            
            try dbConnection.run(
                tab.table.insert(
                    or: or,
                    tab.nameColumn <- name,
                    tab.positionColumn <- position,
                    tab.iconNameColumn <- iconName,
                    tab.foreignKeys.gameColumn <- game,
                    tab.foreignKeys.mapColumn <- map
                )
            )
            
        }
        
        // MARK: TOOL
        
        /// - `TOOL(name, position, assetsImageName, tab, map, game)`
        /// - `PK(name, tab, map, game)`
        /// - `FK(tab, map, game) REFERENCES TAB(name, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoTool(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            name: String,
            position: Int,
            assetsImageName: String,
            game: String,
            map: String,
            tab: String
        ) throws {
            let tool = DBMS.tool
            
            try dbConnection.run(
                tool.table.insert(
                    or: or,
                    tool.nameColumn <- name,
                    tool.positionColumn <- position,
                    tool.assetsImageNameColumn <- assetsImageName,
                    tool.foreignKeys.gameColumn <- game,
                    tool.foreignKeys.mapColumn <- map,
                    tool.foreignKeys.tabColumn <- tab
                )
            )
            
        }
        
        // MARK: GALLERY
        
        /// - `GALLERY(name, assetsImageName, tool, tab, map, game)`
        /// - `PK(name, tool, tab, map, game)`
        /// - `FK(tool, tab, map, game) REFERENCES TOOL(name, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoGallery(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            name: String,
            position: Int,
            assetsImageName: String?,
            game: String,
            map: String,
            tab: String,
            tool: String
        ) throws {
            let gallery = DBMS.gallery
            
            try dbConnection.run(
                gallery.table.insert(
                    or: or,
                    gallery.nameColumn <- name,
                    gallery.positionColumn <- position,
                    gallery.assetsImageNameColumn <- assetsImageName,
                    gallery.foreignKeys.gameColumn <- game,
                    gallery.foreignKeys.mapColumn <- map,
                    gallery.foreignKeys.tabColumn <- tab,
                    gallery.foreignKeys.toolColumn <- tool
                )
            )
            
        }
        
        // MARK: HAS SUBMAP
        /// - `HAS_SUBMAP(master, slave, game)`
        /// - `PK(slave, game)`
        /// - `FK(slave, game) REFERENCES MAP(name, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoHasSubmap(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            master: String,
            slave: String,
            game: String
        ) throws {
            let submap = DBMS.hasSubmap
            
            try dbConnection.run(
                submap.table.insert(
                    or: or,
                    submap.masterColumn <- master,
                    submap.slaveColumn <- slave,
                    submap.foreignKeys.gameColumn <- game
                )
            )
        }
        
        
        // MARK: HAS SUBGALLERY
        
        /// - `HAS_SUBGALLERY(master, slave, tool, tab, map, game)`
        /// - `PK(slave, tool, tab, map, game)`
        /// - `FK(slave, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoHasSubgallery(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            master: String,
            slave: String,
            game: String,
            map: String,
            tab: String,
            tool: String
        ) throws {
            let subgallery = DBMS.subgallery
            
            try dbConnection.run(
                subgallery.table.insert(
                    or: or,
                    subgallery.masterColumn <- master,
                    subgallery.slaveColumn <- slave,
                    subgallery.foreignKeys.gameColumn <- game,
                    subgallery.foreignKeys.mapColumn <- map,
                    subgallery.foreignKeys.tabColumn <- tab,
                    subgallery.foreignKeys.toolColumn <- tool
                )
            )
            
        }
        
        // MARK: GALLERY SEARCH TOKEN
        
        /// - `GALLERY_SEARCH_TOKEN(title, icon, iconColorHex, gallery, tool, tab, map, game)`
        /// - `PK(gallery, tool, tab, map, game)`
        /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoGallerySearchToken(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            title: String,
            icon: String,
            iconColorHex: String,
            game: String,
            map: String,
            tab: String,
            tool: String,
            gallery: String
        ) throws {
            let gallerySearchToken = DBMS.gallerySearchToken
            
            try dbConnection.run(
                gallerySearchToken.table.insert(
                    or: or,
                    gallerySearchToken.titleColumn <- title,
                    gallerySearchToken.iconColumn <- icon,
                    gallerySearchToken.iconColorHexColumn <- iconColorHex,
                    gallerySearchToken.foreignKeys.gameColumn <- game,
                    gallerySearchToken.foreignKeys.mapColumn <- map,
                    gallerySearchToken.foreignKeys.tabColumn <- tab,
                    gallerySearchToken.foreignKeys.toolColumn <- tool,
                    gallerySearchToken.foreignKeys.galleryColumn <- gallery
                )
            )
        }
        
        // MARK: IMAGE
        
        @available(*, unavailable, renamed: "insertIntoVisualMedia")
        /// - `REFERENCES VISUAL_MEDIA(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
        /// - `PK(name, gallery, tool, tab, map, game)`
        /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
        public static func insertIntoImage(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            name: String,
            description: String,
            position: Int,
            searchLabel: String?,
            game: String,
            map: String,
            tab: String,
            tool: String,
            gallery: String
        ) throws {
            let image = DBMS.visualMedia
            
            try dbConnection.run(
                image.table.insert(
                    or: or,
                    image.nameColumn <- name,
                    image.descriptionColumn <- description,
                    image.positionColumn <- position,
                    image.searchLabelColumn <- searchLabel,
                    image.foreignKeys.gameColumn <- game,
                    image.foreignKeys.mapColumn <- map,
                    image.foreignKeys.tabColumn <- tab,
                    image.foreignKeys.toolColumn <- tool,
                    image.foreignKeys.galleryColumn <- gallery
                )
            )
        }
        
        /// - `REFERENCES VISUAL_MEDIA(type, extension, name, description, position, searchLabel, gallery, tool, tab, map, game)`
        /// - `PK(name, gallery, tool, tab, map, game)`
        /// - `FK(gallery, tool, tab, map, game) REFERENCES GALLERY(name, tool, tab, map, game)`
        public static func insertIntoVisualMedia(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            type: VisualMediaType,
            format: String?,
            name: String,
            description: String,
            position: Int,
            searchLabel: String?,
            game: String,
            map: String,
            tab: String,
            tool: String,
            gallery: String
        ) throws {
            let media = DBMS.visualMedia
            
            try dbConnection.run(
                media.table.insert(
                    or: or,
                    media.typeColumn <- type == .image ? "image":"video",
                    media.extensionColumn <- format,
                    media.nameColumn <- name,
                    media.descriptionColumn <- description,
                    media.positionColumn <- position,
                    media.searchLabelColumn <- searchLabel,
                    media.foreignKeys.gameColumn <- game,
                    media.foreignKeys.mapColumn <- map,
                    media.foreignKeys.tabColumn <- tab,
                    media.foreignKeys.toolColumn <- tool,
                    media.foreignKeys.galleryColumn <- gallery
                )
            )
        }

        
        // MARK: IMAGE_VARIANT
        
        /// - `IMAGE_VARIANT(master, slave, variant, bottomBarIcon, boundingFrameOriginX, boundingFrameOriginY, boundingFrameWidth, boundingFrameHeight, gallery, tool, tab, map, game)`
        /// - `PK(slave, gallery, tool, tab, map, game)`
        /// - `FK(slave, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extension, name, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoImageVariant(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            master: String,
            slave: String,
            variant: String,
            bottomBarIcon: String,
            goBackBottomBarIcon: String?,
            boundingFrame: CGRect?,
            game: String,
            map: String,
            tab: String,
            tool: String,
            gallery: String
        ) throws {
            let imageVariant = DBMS.imageVariant
            
            try dbConnection.run(
                imageVariant.table.insert(
                    or: or,
                    imageVariant.masterColumn <- master,
                    imageVariant.slaveColumn <- slave,
                    imageVariant.variantColumn <- variant,
                    imageVariant.bottomBarIconColumn <- bottomBarIcon,
                    imageVariant.goBackBottomBarIconColumn <- goBackBottomBarIcon,
                    imageVariant.boundingFrameOriginXColumn <- boundingFrame == nil ? nil : Double(boundingFrame!.origin.x),
                    imageVariant.boundingFrameOriginYColumn <- boundingFrame == nil ? nil : Double(boundingFrame!.origin.y),
                    imageVariant.boundingFrameWidthColumn <- boundingFrame == nil ? nil : Double(boundingFrame!.size.width),
                    imageVariant.boundingFrameHeightColumn <- boundingFrame == nil ? nil : Double(boundingFrame!.size.height),
                    imageVariant.foreignKeys.gameColumn <- game,
                    imageVariant.foreignKeys.mapColumn <- map,
                    imageVariant.foreignKeys.tabColumn <- tab,
                    imageVariant.foreignKeys.toolColumn <- tool,
                    imageVariant.foreignKeys.galleryColumn <- gallery
                )
            )
            
        }
        
        // MARK: OUTLINE
        
        /// - `OUTLINE(colorHex, isActive, opacity, boundingBoxOriginX, boundingBoxOriginY,boundingBoxWidth, boundingBoxHeight, image, gallery, tool, tab, map, game)`
        /// - `PK(image, gallery, tool, tab, map, game)`
        /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extensionname, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoOutline(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            resourceName: String,
            colorHex: String,
            isActive: Bool,
            opacity: Double,
            boundingBox: CGRect,
            game: String,
            map: String,
            tab: String,
            tool: String,
            gallery: String,
            image: String
        ) throws {
            let outline = DBMS.outline
            try dbConnection.run(
                outline.table.insert(
                    or: or,
                    outline.resourceNameColumn <- resourceName,
                    outline.colorHexColumn <- colorHex,
                    outline.isActiveColumn <- isActive,
                    outline.opacityColumn <- opacity,
                    outline.boundingBoxOriginXColumn <- Double(boundingBox.origin.x),
                    outline.boundingBoxOriginYColumn <- Double(boundingBox.origin.y),
                    outline.boundingBoxWidthColumn <- Double(boundingBox.size.width),
                    outline.boundingBoxHeightColumn <- Double(boundingBox.size.height),
                    outline.foreignKeys.gameColumn <- game,
                    outline.foreignKeys.mapColumn <- map,
                    outline.foreignKeys.tabColumn <- tab,
                    outline.foreignKeys.toolColumn <- tool,
                    outline.foreignKeys.galleryColumn <- gallery,
                    outline.foreignKeys.imageColumn <- image
                )
            )
            
        }
        
        // MARK: BOUNDING CIRCLE
        
        /// - `BOUNDING_CIRCLE(colorHex, isActive, opacity, idleDiameter, normalizedCenterX, normalizedCenterY, image, gallery, tool, tab, map, game)`
        /// - `PK(image, gallery, tool, tab, map, game)`
        /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extensionname, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoBoundingCircle(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            colorHex: String,
            isActive: Bool,
            opacity: Double,
            idleDiameter: Double?,
            normalizedCenter: CGPoint?,
            game: String,
            map: String,
            tab: String,
            tool: String,
            gallery: String,
            image: String
        ) throws {
            let boundingCircle = DBMS.boundingCircle
            
            try dbConnection.run(
                boundingCircle.table.insert(
                    or: or,
                    boundingCircle.colorHexColumn <- colorHex,
                    boundingCircle.isActiveColumn <- isActive,
                    boundingCircle.opacityColumn <- opacity,
                    boundingCircle.idleDiameterColumn <- idleDiameter,
                    boundingCircle.normalizedCenterXColumn <- normalizedCenter == nil ? nil : Double(normalizedCenter!.x),
                    boundingCircle.normalizedCenterYColumn <- normalizedCenter == nil ? nil : Double(normalizedCenter!.y),
                    boundingCircle.foreignKeys.gameColumn <- game,
                    boundingCircle.foreignKeys.mapColumn <- map,
                    boundingCircle.foreignKeys.tabColumn <- tab,
                    boundingCircle.foreignKeys.toolColumn <- tool,
                    boundingCircle.foreignKeys.galleryColumn <- gallery,
                    boundingCircle.foreignKeys.imageColumn <- image
                )
            )
            
        }
        
        // MARK: LABEL
        
        /// - `LABEL(label, isActive, icon, assetsImageName, textColorHex, backgroundColorHex, opacity, maxAABBOriginX, maxAABBOriginY, maxAABBWidth, maxAABBHeight, image, gallery, tool, tab, map, game)`
        /// - `PK(label, image, gallery, tool, tab, map, game)`
        /// - `FK(image, gallery, tool, tab, map, game) REFERENCES REFERENCES VISUAL_MEDIA(type, extensionname, gallery, tool, tab, map, game) ON DELETE CASCADE ON UPDATE CASCADE`
        public static func insertIntoLabel(
            or: OnConflict = .fail,
            for dbConnection: Connection,
            label: String,
            isActive: Bool,
            icon: String?,
            assetsImageName: String?,
            textColorHex: String,
            backgroundColorHex: String,
            opacity: Double,
            maxAABB: CGRect?,
            game: String,
            map: String,
            tab: String,
            tool: String,
            gallery: String,
            image: String
        ) throws {
            let labelModel = DBMS.label
            
            try dbConnection.run(
                labelModel.table.insert(
                    or: or,
                    labelModel.labelColumn <- label,
                    labelModel.isActiveColumn <- isActive,
                    labelModel.iconColumn <- icon,
                    labelModel.assetsImageNameColumn <- assetsImageName,
                    labelModel.textColorHexColumn <- textColorHex,
                    labelModel.backgroundColorHexColumn <- backgroundColorHex,
                    labelModel.opacityColumn <- opacity,
                    labelModel.maxAABBOriginXColumn <- maxAABB == nil ? nil : Double(maxAABB!.origin.x),
                    labelModel.maxAABBOriginYColumn <- maxAABB == nil ? nil : Double(maxAABB!.origin.y),
                    labelModel.maxAABBWidthColumn <- maxAABB == nil ? nil : Double(maxAABB!.size.width),
                    labelModel.maxAABBHeightColumn <- maxAABB == nil ? nil : Double(maxAABB!.size.height),
                    labelModel.foreignKeys.gameColumn <- game,
                    labelModel.foreignKeys.mapColumn <- map,
                    labelModel.foreignKeys.tabColumn <- tab,
                    labelModel.foreignKeys.toolColumn <- tool,
                    labelModel.foreignKeys.galleryColumn <- gallery,
                    labelModel.foreignKeys.imageColumn <- image
                )
            )
            
        }
    }
}
