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
    
}

public enum ReadImageOption {
    case images
    case outlines
    case boundingCircles
    case labels
    case variantsMetadatas
}

extension Set where Element == ReadImageOption {
    public static let all = Set<Element>([
        .images, .outlines, .boundingCircles, .labels, .variantsMetadatas
    ])
}
