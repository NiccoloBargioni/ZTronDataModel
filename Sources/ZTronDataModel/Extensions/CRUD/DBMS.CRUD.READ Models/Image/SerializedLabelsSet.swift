import Foundation

public final class SerializedLabelsSet: ReadImageOptional {
    private let labels: [SerializedLabelModel]
    
    internal init(labels: [SerializedLabelModel]) {
        self.labels = labels
    }
    
    public static func == (lhs: SerializedLabelsSet, rhs: SerializedLabelsSet) -> Bool {
        if lhs.labels.count != rhs.labels.count {
            return false
        } else {
            for i in 0..<lhs.labels.count {
                if lhs.labels[i] != rhs.labels[i] {
                    return false
                }
            }
            
            return true
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        for label in labels {
            hasher.combine(label)
        }
    }
    
    public func getLabels() -> [SerializedLabelModel] {
        return self.labels
    }
    
}
