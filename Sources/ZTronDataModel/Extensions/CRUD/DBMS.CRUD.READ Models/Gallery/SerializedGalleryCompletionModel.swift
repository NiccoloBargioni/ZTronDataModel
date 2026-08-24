import Foundation

public final class SerializedGalleryCompletionModel: ReadGalleryOptional {
    private let name: String
    private let depth: Int
    private let completionMin: Double?
    private let completionMax: Double?
    
    public init(name: String, depth: Int, completionMin: Double?, completionMax: Double?) {
        self.name = name
        self.depth = depth
        self.completionMin = completionMin
        self.completionMax = completionMax
    }
    
    public final func getName() -> String {
        return self.name
    }
    
    public final func getDepth() -> Int {
        return self.depth
    }
    
    public final func getCompletionMin() -> Double? {
        return self.completionMin
    }
    
    public final func getCompletionMax() -> Double? {
        return self.completionMax
    }
    
    public static func == (lhs: SerializedGalleryCompletionModel, rhs: SerializedGalleryCompletionModel) -> Bool {
        return lhs.name == rhs.name && lhs.depth == rhs.depth && lhs.completionMin == rhs.completionMin && lhs.completionMax == rhs.completionMax
    }
    
    public final func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}


