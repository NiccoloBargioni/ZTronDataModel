import Foundation

public final class SerializedImageVariantsMetadataSet: ReadImageOptional {
    private let variants: [SerializedImageVariantMetadataModel]
    
    internal init(variants: [SerializedImageVariantMetadataModel]) {
        self.variants = variants
    }
    
    public static func == (lhs: SerializedImageVariantsMetadataSet, rhs: SerializedImageVariantsMetadataSet) -> Bool {
        if lhs.variants.count != rhs.variants.count {
            return false
        } else {
            for i in 0..<lhs.variants.count {
                if lhs.variants[i] != rhs.variants[i] {
                    return false
                }
            }
            
            return true
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        for variant in variants {
            hasher.combine(variant)
        }
    }

    public func getVariants() -> [SerializedImageVariantMetadataModel] {
        return self.variants
    }
}
