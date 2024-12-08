import Foundation
import SQLite3
import SQLite

extension String: ReadImageOptional { }
extension String: ReadGalleryOptional {  }

extension DBMS.CRUD {
    //MARK: - READ IMAGE VARIANTS
    private static func readFirstLevelMasterImagesForGallery(
        for dbConnection: Connection,
        game: String,
        map: String,
        tab: String,
        tool: String,
        gallery: String
    ) throws -> [SerializedImageModel] {
        let image = DBMS.image
        let imageVariant = DBMS.imageVariant
        
        let findSlavesQuery = imageVariant.table
            .select(imageVariant.slaveColumn)
            .filter(
                imageVariant.foreignKeys.gameColumn == game &&
                imageVariant.foreignKeys.mapColumn == map &&
                imageVariant.foreignKeys.tabColumn == tab &&
                imageVariant.foreignKeys.toolColumn == tool &&
                imageVariant.foreignKeys.galleryColumn == gallery
            )
        
        let slaves = try dbConnection.prepare(findSlavesQuery).map { result in
            return result[imageVariant.slaveColumn]
        }
        
        let firstLevelMastersQuery = image.table.filter(
            image.foreignKeys.gameColumn == game &&
            image.foreignKeys.mapColumn == map &&
            image.foreignKeys.tabColumn == tab &&
            image.foreignKeys.toolColumn == tool &&
            image.foreignKeys.galleryColumn == gallery &&
            !slaves.contains(image.nameColumn)
        )
        .order(image.positionColumn)
        
        
        return try dbConnection.prepare(firstLevelMastersQuery).map { imageRow in
            return SerializedImageModel(imageRow)
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
        let imageModel = DBMS.image
        
        let findImageQuery = imageModel.table.filter(
            imageModel.nameColumn == image &&
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
    
    
    public static func readImageByIDWithOptions(
        for dbConnection: Connection,
        image: String,
        gallery: String,
        tool: String,
        tab: String,
        map: String,
        game: String,
        options: Set<ReadImageOption> = Set<ReadImageOption>([.images])
    ) throws -> [ReadImageOption: [(any ReadImageOptional)?]] {
        let imageTable = DBMS.image
        let imageVariants = DBMS.imageVariant
        let outline = DBMS.outline
        let boundingCircle = DBMS.boundingCircle
        let label = DBMS.label
        
        let parentView = SQLite.View("parentView")
        
        try dbConnection.run(
            parentView.create(
                imageTable.table
                    .join(
                        .leftOuter,
                        imageVariants.table,
                        on: imageTable.nameColumn == imageVariants.slaveColumn &&
                        imageTable.table[imageTable.foreignKeys.galleryColumn] == imageVariants.table[imageVariants.foreignKeys.galleryColumn] &&
                        imageTable.table[imageTable.foreignKeys.toolColumn] == imageVariants.table[imageVariants.foreignKeys.toolColumn] &&
                        imageTable.table[imageTable.foreignKeys.tabColumn] == imageVariants.table[imageVariants.foreignKeys.tabColumn] &&
                        imageTable.table[imageTable.foreignKeys.mapColumn] == imageVariants.table[imageVariants.foreignKeys.mapColumn] &&
                        imageTable.table[imageTable.foreignKeys.gameColumn] == imageVariants.table[imageVariants.foreignKeys.gameColumn]
                    )
                    .filter(
                        imageTable.nameColumn == image &&
                        imageTable.table[imageTable.foreignKeys.galleryColumn] == gallery &&
                        imageTable.table[imageTable.foreignKeys.toolColumn] == tool &&
                        imageTable.table[imageTable.foreignKeys.tabColumn] == tab &&
                        imageTable.table[imageTable.foreignKeys.mapColumn] == map &&
                        imageTable.table[imageTable.foreignKeys.gameColumn] == game
                    )
                    .select(
                        [
                            imageTable.nameColumn.alias(name: "childImage"),
                            imageVariants.masterColumn.alias(name: "parent"),
                            imageTable.table[imageTable.foreignKeys.galleryColumn],
                            imageTable.table[imageTable.foreignKeys.toolColumn],
                            imageTable.table[imageTable.foreignKeys.tabColumn],
                            imageTable.table[imageTable.foreignKeys.mapColumn],
                            imageTable.table[imageTable.foreignKeys.gameColumn]
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

        
        let sql = imageTable.table.join(
            .leftOuter,
            imageVariants.table,
            on: imageTable.table[imageTable.nameColumn] == imageVariants.table[imageVariants.masterColumn] &&
            imageTable.table[imageTable.foreignKeys.galleryColumn] == imageVariants.table[imageVariants.foreignKeys.galleryColumn] &&
            imageTable.table[imageTable.foreignKeys.toolColumn] == imageVariants.table[imageVariants.foreignKeys.toolColumn] &&
            imageTable.table[imageTable.foreignKeys.tabColumn] == imageVariants.table[imageVariants.foreignKeys.tabColumn] &&
            imageTable.table[imageTable.foreignKeys.mapColumn] == imageVariants.table[imageVariants.foreignKeys.mapColumn] &&
            imageTable.table[imageTable.foreignKeys.gameColumn] == imageVariants.table[imageVariants.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            parentView,
            on: imageTable.table[imageTable.nameColumn] == parentView[parentViewChild] &&
            imageTable.table[imageTable.foreignKeys.galleryColumn] == parentView[imageTable.foreignKeys.galleryColumn] &&
            imageTable.table[imageTable.foreignKeys.toolColumn] == parentView[imageTable.foreignKeys.toolColumn] &&
            imageTable.table[imageTable.foreignKeys.tabColumn] == parentView[imageTable.foreignKeys.tabColumn] &&
            imageTable.table[imageTable.foreignKeys.mapColumn] == parentView[imageTable.foreignKeys.mapColumn] &&
            imageTable.table[imageTable.foreignKeys.gameColumn] == parentView[imageTable.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            outline.table,
            on: imageTable.table[imageTable.nameColumn] == outline.table[outline.foreignKeys.imageColumn] &&
            imageTable.table[imageTable.foreignKeys.galleryColumn] == outline.table[outline.foreignKeys.galleryColumn] &&
            imageTable.table[imageTable.foreignKeys.toolColumn] == outline.table[outline.foreignKeys.toolColumn] &&
            imageTable.table[imageTable.foreignKeys.tabColumn] == outline.table[outline.foreignKeys.tabColumn] &&
            imageTable.table[imageTable.foreignKeys.mapColumn] == outline.table[outline.foreignKeys.mapColumn] &&
            imageTable.table[imageTable.foreignKeys.gameColumn] == outline.table[outline.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            boundingCircle.table,
            on: imageTable.table[imageTable.nameColumn] == boundingCircle.table[boundingCircle.foreignKeys.imageColumn] &&
            imageTable.table[imageTable.foreignKeys.galleryColumn] == boundingCircle.table[boundingCircle.foreignKeys.galleryColumn] &&
            imageTable.table[imageTable.foreignKeys.toolColumn] == boundingCircle.table[boundingCircle.foreignKeys.toolColumn] &&
            imageTable.table[imageTable.foreignKeys.tabColumn] == boundingCircle.table[boundingCircle.foreignKeys.tabColumn] &&
            imageTable.table[imageTable.foreignKeys.mapColumn] == boundingCircle.table[boundingCircle.foreignKeys.mapColumn] &&
            imageTable.table[imageTable.foreignKeys.gameColumn] == boundingCircle.table[boundingCircle.foreignKeys.gameColumn]
        ).join(
            .leftOuter,
            label.table,
            on: imageTable.table[imageTable.nameColumn] == label.table[label.foreignKeys.imageColumn] &&
            imageTable.table[imageTable.foreignKeys.galleryColumn] == label.table[label.foreignKeys.galleryColumn] &&
            imageTable.table[imageTable.foreignKeys.toolColumn] == label.table[label.foreignKeys.toolColumn] &&
            imageTable.table[imageTable.foreignKeys.tabColumn] == label.table[label.foreignKeys.tabColumn] &&
            imageTable.table[imageTable.foreignKeys.mapColumn] == label.table[label.foreignKeys.mapColumn] &&
            imageTable.table[imageTable.foreignKeys.gameColumn] == label.table[label.foreignKeys.gameColumn]
        ).filter(
            imageTable.table[imageTable.nameColumn] == image &&
            imageTable.table[imageTable.foreignKeys.galleryColumn] == gallery &&
            imageTable.table[imageTable.foreignKeys.toolColumn] == tool &&
            imageTable.table[imageTable.foreignKeys.tabColumn] == tab &&
            imageTable.table[imageTable.foreignKeys.mapColumn] == map &&
            imageTable.table[imageTable.foreignKeys.gameColumn] == game
        ).select(
            imageTable.table[imageTable.nameColumn],
            imageTable.table[imageTable.descriptionColumn],
            imageTable.table[imageTable.positionColumn],
            imageTable.table[imageTable.searchLabelColumn],
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
            imageTable.table[imageTable.foreignKeys.galleryColumn],
            imageTable.table[imageTable.foreignKeys.toolColumn],
            imageTable.table[imageTable.foreignKeys.tabColumn],
            imageTable.table[imageTable.foreignKeys.mapColumn],
            imageTable.table[imageTable.foreignKeys.gameColumn]
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
                        image: result[imageTable.table[imageTable.nameColumn]],
                        gallery: result[imageTable.table[imageTable.foreignKeys.galleryColumn]],
                        tool: result[imageTable.table[imageTable.foreignKeys.toolColumn]],
                        tab: result[imageTable.table[imageTable.foreignKeys.tabColumn]],
                        map: result[imageTable.table[imageTable.foreignKeys.mapColumn]],
                        game: result[imageTable.table[imageTable.foreignKeys.gameColumn]]
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
                        image: result[imageTable.table[imageTable.nameColumn]],
                        gallery: result[imageTable.table[imageTable.foreignKeys.galleryColumn]],
                        tool: result[imageTable.table[imageTable.foreignKeys.toolColumn]],
                        tab: result[imageTable.table[imageTable.foreignKeys.tabColumn]],
                        map: result[imageTable.table[imageTable.foreignKeys.mapColumn]],
                        game: result[imageTable.table[imageTable.foreignKeys.gameColumn]]
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
                    image: result[imageTable.table[imageTable.nameColumn]],
                    gallery: result[imageTable.table[imageTable.foreignKeys.galleryColumn]],
                    tool: result[imageTable.table[imageTable.foreignKeys.toolColumn]],
                    tab: result[imageTable.table[imageTable.foreignKeys.tabColumn]],
                    map: result[imageTable.table[imageTable.foreignKeys.mapColumn]],
                    game: result[imageTable.table[imageTable.foreignKeys.gameColumn]]
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
                    gallery: result[imageTable.table[imageTable.foreignKeys.galleryColumn]],
                    tool: result[imageTable.table[imageTable.foreignKeys.toolColumn]],
                    tab: result[imageTable.table[imageTable.foreignKeys.tabColumn]],
                    map: result[imageTable.table[imageTable.foreignKeys.mapColumn]],
                    game: result[imageTable.table[imageTable.foreignKeys.gameColumn]]
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
            result[.images] = [image]
            
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

        assert(result[.images]?.count ?? 0 == 1)
        assert(result[.outlines]?.count ?? 0 <= 1)
        assert(result[.boundingCircles]?.count ?? 0 <= 1)
        assert(result[.labels]?.count ?? 0 <= 1)
        assert(result[.variantsMetadatas]?.count ?? 0 <= 1)
        assert(result[.masters]?.count ?? 0 <= 1)
        
        return result
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
    
    
    private static func readOutlinesForImagesSet(for dbConnection: Connection, images: [SerializedImageModel]) throws -> [SerializedOutlineModel?] {
        let outline = DBMS.outline
        
        var outlines: [SerializedOutlineModel?] = []
        
        for image in images {
            let outlinesForThisImageQuery = outline.table.filter(
                outline.foreignKeys.imageColumn == image.getName() &&
                outline.foreignKeys.galleryColumn == image.getGallery() &&
                outline.foreignKeys.toolColumn == image.getTool() &&
                outline.foreignKeys.tabColumn == image.getTab() &&
                outline.foreignKeys.mapColumn == image.getMap() &&
                outline.foreignKeys.gameColumn == image.getGame()
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
        }
        
        return outlines
    }

    private static func readBoundingCirclesForImagesSet(for dbConnection: Connection, images: [SerializedImageModel]) throws -> [SerializedBoundingCircleModel?] {
        let boundingCircle = DBMS.boundingCircle
        
        var boundingCircles: [SerializedBoundingCircleModel?] = []
        
        for image in images {
            let boundingCirclesForThisImageQuery = boundingCircle.table.filter(
                boundingCircle.foreignKeys.imageColumn == image.getName() &&
                boundingCircle.foreignKeys.galleryColumn == image.getGallery() &&
                boundingCircle.foreignKeys.toolColumn == image.getTool() &&
                boundingCircle.foreignKeys.tabColumn == image.getTab() &&
                boundingCircle.foreignKeys.mapColumn == image.getMap() &&
                boundingCircle.foreignKeys.gameColumn == image.getGame()
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
        }
        
        return boundingCircles
    }
    
    private static func readLabelsForImagesSet(for dbConnection: Connection, images: [SerializedImageModel]) throws -> [SerializedLabelsSet?] {
        let label = DBMS.label
        
        var labels: [SerializedLabelsSet?] = []
        
        for image in images {
            let labelsForThisImageQuery = label.table.filter(
                label.foreignKeys.imageColumn == image.getName() &&
                label.foreignKeys.galleryColumn == image.getGallery() &&
                label.foreignKeys.toolColumn == image.getTool() &&
                label.foreignKeys.tabColumn == image.getTab() &&
                label.foreignKeys.mapColumn == image.getMap() &&
                label.foreignKeys.gameColumn == image.getGame()
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
        }
        
        return labels
    }
    
    private static func readVariantsMetadataForImagesSet(for dbConnection: Connection, images: [SerializedImageModel]) throws -> [SerializedImageVariantsMetadataSet?] {
        let variant = DBMS.imageVariant
        
        var variants: [SerializedImageVariantsMetadataSet?] = []
        
        for image in images.enumerated() {
            let variantsForThisImageQuery = variant.table.filter(
                variant.masterColumn == image.element.getName() &&
                variant.foreignKeys.galleryColumn == image.element.getGallery() &&
                variant.foreignKeys.toolColumn == image.element.getTool() &&
                variant.foreignKeys.tabColumn == image.element.getTab() &&
                variant.foreignKeys.mapColumn == image.element.getMap() &&
                variant.foreignKeys.gameColumn == image.element.getGame()
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
        }
        
        return variants
    }
    
    /// Returns from database the set of all the top level `master`s for the specified gallery, along with the requested optionals.
    ///
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
        gallery: String,
        options: Set<ReadImageOption> = Set<ReadImageOption>([.images])
    ) throws -> [ReadImageOption: [(any ReadImageOptional)?]] {
        var imagesWithOptionals: [ReadImageOption: [(any ReadImageOptional)?]] = [:]
        
        let images = try self.readFirstLevelMasterImagesForGallery(
            for: dbConnection,
            game: game,
            map: map,
            tab: tab,
            tool: tool,
            gallery: gallery
        )
        
        if options.contains(.outlines) {
            imagesWithOptionals[.outlines] = try self.readOutlinesForImagesSet(for: dbConnection, images: images)
            assert(images.count == imagesWithOptionals[.outlines]?.count)
        }
        
        if options.contains(.boundingCircles) {
            imagesWithOptionals[.boundingCircles] = try self.readBoundingCirclesForImagesSet(
                for: dbConnection,
                images: images
            )
            assert(images.count == imagesWithOptionals[.boundingCircles]?.count)
        }
        
        if options.contains(.labels) {
            imagesWithOptionals[.labels] = try self.readLabelsForImagesSet(for: dbConnection, images: images)
            assert(images.count == imagesWithOptionals[.labels]?.count)
        }
        
        if options.contains(.variantsMetadatas) {
            imagesWithOptionals[.variantsMetadatas] = try self.readVariantsMetadataForImagesSet(
                for: dbConnection,
                images: images
            )
            assert(images.count == imagesWithOptionals[.variantsMetadatas]?.count)
        }
        
        if options.contains(.masters) {
            imagesWithOptionals[.masters] = [String?].init(repeating: nil, count: images.count)
        }
        
        imagesWithOptionals[.images] = images
        
        return imagesWithOptionals
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
    ///
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
    ) throws -> [ReadGalleryOption: [(any ReadGalleryOptional)]] {
        var galleriesWithOptions: [ReadGalleryOption: [(any ReadGalleryOptional)]] = [:]
        
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
        
        return galleriesWithOptions
    }
}

public enum ReadImageOption: Sendable {
    case images
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
}

extension Set where Element == ReadImageOption {
    public static let all = Set<Element>([
        .images, .outlines, .boundingCircles, .labels, .variantsMetadatas
    ])
}
