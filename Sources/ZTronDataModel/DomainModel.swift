import Foundation

internal class DomainModel {
    internal static let studio = Studio()
    internal static let game = Game()
    internal static let map = Map()
    internal static let tab = Tab()
    internal static let tool = Tool()
    internal static let gallery = Gallery()
    internal static let subgallery = HasSubgallery()
    internal static let gallerySearchToken = GallerySearchToken()
    internal static let visualMedia = VisualMedia()
    internal static let imageVariant = ImageVariant()
    internal static let outline = Outline()
    internal static let boundingCircle = BoundingCircle()
    internal static let label = Label()
    
    internal static let allTablesCreators: [any DBTableCreator] = [
        DomainModel.studio, DomainModel.game, DomainModel.map, DomainModel.tab, DomainModel.tool,
        DomainModel.gallery, DomainModel.subgallery, DomainModel.gallerySearchToken, DomainModel.visualMedia,
        DomainModel.imageVariant, DomainModel.outline, DomainModel.boundingCircle, DomainModel.label
    ]
    
    private init() { }
}
