import Foundation
import SQLite3
import SQLite

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
        game: String
    ) throws -> [ReadImageOption: [(any ReadImageOptional)?]] {
        let imageTable = DBMS.image
        let imageVariants = DBMS.imageVariant
        let outline = DBMS.outline
        let boundingCircle = DBMS.boundingCircle
        let label = DBMS.label
        
        let selectQueryStatement: String = """
        WITH parentImage AS (
        SELECT
            \(imageTable.tableName).\(imageTable.nameColumn.template) AS childImage,
            \(imageVariants.tableName).\(imageVariants.masterColumn.template) AS parent
        FROM
            \(imageTable.tableName)
        LEFT OUTER JOIN
            \(imageVariants.tableName)
        ON
            \(imageTable.tableName).\(imageTable.nameColumn.template) = \(imageVariants.tableName).\(imageVariants.slaveColumn.template)
            AND \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.galleryColumn.template)
            AND \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.toolColumn.template)
            AND \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.tabColumn.template)
            AND \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.mapColumn.template)
            AND \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.gameColumn.template)
        WHERE
            \(imageTable.tableName).\(imageTable.nameColumn.template) = "\(image)" AND
            \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn.template) = "\(gallery)" AND
            \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn.template) = "\(tool)" AND
            \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn.template) = "\(tab)" AND
            \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn.template) = "\(map)" AND
            \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn.template) = "\(game)"
        )
        SELECT  \(imageTable.tableName).\(imageTable.nameColumn.template),                                                          /*0*/
                     \(imageTable.tableName).\(imageTable.descriptionColumn.template),                                              /*1*/
                     \(imageTable.tableName).\(imageTable.positionColumn.template),                                                 /*2*/                 
                     \(imageTable.tableName).\(imageTable.searchLabelColumn.template),                                              /*3*/
                     \(imageVariants.tableName).\(imageVariants.masterColumn),                                                      /*4*/
                     \(imageVariants.tableName).\(imageVariants.slaveColumn.template),                                              /*5*/
                     \(imageVariants.tableName).\(imageVariants.variantColumn.template),                                            /*6*/
                     \(imageVariants.tableName).\(imageVariants.bottomBarIconColumn.template),                                      /*7*/                                         
                     \(imageVariants.tableName).\(imageVariants.goBackBottomBarIconColumn.template),                                /*8*/
                     \(imageVariants.tableName).\(imageVariants.boundingFrameOriginXColumn.template),                               /*9*/
                     \(imageVariants.tableName).\(imageVariants.boundingFrameOriginYColumn.template),                               /*10*/
                     \(imageVariants.tableName).\(imageVariants.boundingFrameWidthColumn.template),                                 /*11*/
                     \(imageVariants.tableName).\(imageVariants.boundingFrameHeightColumn.template),                                /*12*/
                     parentImage.parent as parentImage,                                                                             /*13*/
                     \(outline.tableName).\(outline.resourceNameColumn.template),                                                   /*14*/
                     \(outline.tableName).\(outline.colorHexColumn.template) as outlineColorHex,                                    /*15*/
                     \(outline.tableName).\(outline.opacityColumn.template) as outlineOpacity,                                      /*16*/
                     \(outline.tableName).\(outline.isActiveColumn.template) as isOutlineActive,                                    /*17*/
                     \(outline.tableName).\(outline.boundingBoxOriginXColumn.template) as outlineBountingBoxOriginX,                /*18*/
                     \(outline.tableName).\(outline.boundingBoxOriginYColumn.template) as outlineBoundingBoxOriginY,                /*19*/
                     \(outline.tableName).\(outline.boundingBoxWidthColumn.template) as outlineBoundingBoxWidth,                    /*20*/
                     \(outline.tableName).\(outline.boundingBoxHeightColumn.template) as outlineBoundingBoxHeight,                  /*21*/
                     \(boundingCircle.tableName).\(boundingCircle.colorHexColumn.template) as boundingCircleColorHex,               /*22*/
                     \(boundingCircle.tableName).\(boundingCircle.opacityColumn.template) as boundingCircleOpacity,                 /*23*/
                     \(boundingCircle.tableName).\(boundingCircle.isActiveColumn.template) as isBoundingCircleActive,               /*24*/
                     \(boundingCircle.tableName).\(boundingCircle.idleDiameterColumn.template),                                     /*25*/
                     \(boundingCircle.tableName).\(boundingCircle.normalizedCenterXColumn.template),                                /*26*/
                     \(boundingCircle.tableName).\(boundingCircle.normalizedCenterYColumn.template),                                /*27*/
                     \(label.tableName).\(label.labelColumn.template),                                                              /*28*/
                     \(label.tableName).\(label.isActiveColumn.template) as isLabelActive,                                          /*29*/
                     \(label.tableName).\(label.iconColumn.template) as labelIcon,                                                  /*30*/
                     \(label.tableName).\(label.assetsImageNameColumn.template) as labelAssetsImageName,                            /*31*/
                     \(label.tableName).\(label.textColorHexColumn.template) as labelTextColorHex,                                  /*32*/
                     \(label.tableName).\(label.backgroundColorHexColumn.template) as labelBackgroundColorHex,                      /*33*/
                     \(label.tableName).\(label.opacityColumn.template) as labelOpacity,                                            /*34*/
                     \(label.tableName).\(label.maxAABBOriginXColumn.template),                                                     /*35*/
                     \(label.tableName).\(label.maxAABBOriginYColumn.template),                                                     /*36*/    
                     \(label.tableName).\(label.maxAABBWidthColumn.template),                                                       /*37*/
                     \(label.tableName).\(label.maxAABBHeightColumn.template),                                                      /*38*/
                     \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn),                                               /*39*/
                     \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn),                                                  /*40*/
                     \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn),                                                   /*41*/
                     \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn),                                                   /*42*/
                     \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn)                                                   /*43*/
             FROM \(imageTable.tableName) LEFT OUTER JOIN \(imageVariants.tableName) ON
                                     \(imageTable.tableName).\(imageTable.nameColumn.template) = \(imageVariants.tableName).\(imageVariants.masterColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.galleryColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.toolColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.tabColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.mapColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn.template) = \(imageVariants.tableName).\(imageVariants.foreignKeys.gameColumn.template)
                                     LEFT OUTER JOIN parentImage ON
                                     \(imageTable.tableName).\(imageTable.nameColumn.template) = parentImage.childImage
                                     LEFT OUTER JOIN \(outline.tableName) ON
                                     \(imageTable.tableName).\(imageTable.nameColumn.template) = \(outline.tableName).\(outline.foreignKeys.imageColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn.template) = \(outline.tableName).\(outline.foreignKeys.galleryColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn.template) = \(outline.tableName).\(outline.foreignKeys.toolColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn.template) = \(outline.tableName).\(outline.foreignKeys.tabColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn.template) = \(outline.tableName).\(outline.foreignKeys.mapColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn.template) = \(outline.tableName).\(outline.foreignKeys.gameColumn.template)
                                     LEFT OUTER JOIN \(boundingCircle.tableName) ON
                                     \(imageTable.tableName).\(imageTable.nameColumn.template) = \(boundingCircle.tableName).\(boundingCircle.foreignKeys.imageColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn.template) = \(boundingCircle.tableName).\(boundingCircle.foreignKeys.galleryColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn.template) = \(boundingCircle.tableName).\(boundingCircle.foreignKeys.toolColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn.template) = \(boundingCircle.tableName).\(boundingCircle.foreignKeys.tabColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn.template) = \(boundingCircle.tableName).\(boundingCircle.foreignKeys.mapColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn.template) = \(boundingCircle.tableName).\(boundingCircle.foreignKeys.gameColumn.template)
                                     LEFT OUTER JOIN \(label.tableName) ON
                                     \(imageTable.tableName).\(imageTable.nameColumn.template) = \(label.tableName).\(label.foreignKeys.imageColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn.template) = \(label.tableName).\(label.foreignKeys.galleryColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn.template) = \(label.tableName).\(label.foreignKeys.toolColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn.template) = \(label.tableName).\(label.foreignKeys.tabColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn.template) = \(label.tableName).\(label.foreignKeys.mapColumn.template) AND
                                     \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn.template) = \(label.tableName).\(label.foreignKeys.gameColumn.template)
            WHERE   \(imageTable.tableName).\(imageTable.nameColumn.template) = "\(image)" AND
                    \(imageTable.tableName).\(imageTable.foreignKeys.galleryColumn.template) = "\(gallery)" AND
                    \(imageTable.tableName).\(imageTable.foreignKeys.toolColumn.template) = "\(tool)" AND
                    \(imageTable.tableName).\(imageTable.foreignKeys.tabColumn.template) = "\(tab)" AND
                    \(imageTable.tableName).\(imageTable.foreignKeys.mapColumn.template) = "\(map)" AND
                    \(imageTable.tableName).\(imageTable.foreignKeys.gameColumn.template) = "\(game)"
        """
        
        
        let dbHandle = dbConnection.handle
        
        var selectStatement: OpaquePointer?
        
        guard sqlite3_prepare_v2(dbHandle, selectQueryStatement, -1, &selectStatement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(dbHandle)!)
            throw SQLQueryError.readError(reason: errmsg)
        }

        var rc = sqlite3_step(selectStatement)

        /*
         * Image: [0,3] U [39, 43]
         * Variant (where image is master): [4,12]
         * Parent: [13]
         * Outline: [14, 21] U [39, 43]
         * Bounding circle: [22, 27] U [39, 43]
         * Label: [28, 38] U [39, 43]
         * Foreign keys: [39, 43]
         */
        var imageDictionary: [String: (name: String, description: String, position: Int, searchLabel: String?)] = [:]
        
        while rc == SQLITE_ROW {
            guard let id = sqlite3_column_text(selectStatement, 0) else {
                throw SQLQueryError.readError(reason: "Could not read column 0 with name \(imageTable.nameColumn.template) of result as text in \(#function) @ \(#file):\(#line)")
            }
            
            let imageName = String(cString: id)
            
            if imageDictionary[imageName] == nil {
                guard let descrption = sqlite3_column_text(selectStatement, 1) else {
                    throw SQLQueryError.readError(reason: "Could not read column 1 with name \(imageTable.descriptionColumn.template) of result as text in \(#function) @ \(#file):\(#line)")
                }
                
                let imagePosition = sqlite3_column_int(selectStatement, 2)
                guard imagePosition != SQLITE_NULL else {
                    throw SQLQueryError.readError(reason: "Could not read column 2 with name \(imageTable.positionColumn.template) of result as text in \(#function) @ \(#file):\(#line)")
                }
                
                guard let searchLabel = sqlite3_column_text(selectStatement, 3) else {
                    throw SQLQueryError.readError(reason: "Could not read column 3 with name \(imageTable.searchLabelColumn.template) of result as text in \(#function) @ \(#file):\(#line)")
                }
                
                imageDictionary[imageName] = (
                    name: imageName,
                    description: String(cString: descrption),
                    position: Int(imagePosition),
                    searchLabel: sqlite3_column_type(selectStatement, 3) != SQLITE_NULL ? String(cString: searchLabel) : nil
                )
            }
            
            rc = sqlite3_step(selectStatement)
        }

        if rc != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(dbHandle)!)
            throw SQLQueryError.readError(reason: errmsg)
        }

        
        print(#function)
        imageDictionary.keys.forEach { image in
            Self.logger.error("""
            IMAGE(
                  name: \(imageDictionary[image]!.name),
                  description: \(imageDictionary[image]!.description),
                  position: \(imageDictionary[image]!.position),
                  searchLabel: \(String(describing: imageDictionary[image]!.searchLabel)
            )
            """)
        }

        // clean up when we're done

        sqlite3_finalize(selectStatement)
        return [:]
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
}

public enum ReadGalleryOption: Sendable {
    case galleries
    case searchToken
}

extension Set where Element == ReadImageOption {
    public static let all = Set<Element>([
        .images, .outlines, .boundingCircles, .labels, .variantsMetadatas
    ])
}
