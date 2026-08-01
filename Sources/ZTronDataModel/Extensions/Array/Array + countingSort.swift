import Foundation

/// Sorts an array of non-negative integers. The non-negativity is not enforced by this function and must be guaranteed by the caller,
///
/// - Complexity: O(array.count + max(array)) for both space and time.
private func countingSort(_ array: [Int])-> [Int] {
  guard array.count > 0 else { return [] }
    var arrayCopy = Array(array)
    
    let min = array.min()!
    
    if min < 0 {
        for i in 0..<arrayCopy.count {
            arrayCopy[i] -= min
        }
    }
    
    let maxElement = arrayCopy.max()!

    var countArray = [Int](repeating: 0, count: Int(maxElement + 1))
    
    for element in arrayCopy {
        countArray[element] += 1
    }

    for index in 1 ..< countArray.count {
        let sum = countArray[index] + countArray[index - 1]
        countArray[index] = sum
    }

    var sortedArray = [Int](repeating: 0, count: arrayCopy.count)
        
    for index in stride(from: arrayCopy.count - 1, through: 0, by: -1) {
        let element = arrayCopy[index]
        countArray[element] -= 1
        sortedArray[countArray[element]] = element
    }

    if min < 0 {
        for i in 0..<sortedArray.count {
            sortedArray[i] += min
        }
    }
    
    return sortedArray
}


internal extension Array where Element == Int {
    func countingSorted() -> Self {
        return countingSort(self)
    }
}
