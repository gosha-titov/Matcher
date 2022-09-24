import ModKit

typealias OptionalSequence = [Int?]
typealias Subsequence = [Int]
typealias Sequence = [Int]


final class MathBox {
    
    // MARK: Extract Char Positions
    
    /// Decomposes the given text into chars and indexes where they are placed.
    ///
    ///     let text = "Robot"
    ///     let dict = extractCharPositions(from: text)
    ///     // ["r": [0], "o": [1, 3], "b": [2], "t": [4]]
    ///
    /// Letter case does not affect the result.
    ///
    /// - Returns: A dictionary where each char keeps its own indexes.
    ///
    static func extractCharPositions(from text: String) -> [Character: [Int]] {
        var dict = [Character: [Int]]()
        for (index, char) in text.lowercased().enumerated() {
            if dict.hasKey(char) {
                dict[char]!.append(index)
            } else {
                dict[char] = [index]
            }
        }
        return dict
    }
    
    
    // MARK: Find Lis
    
    /// Finds the longest increasing subsequence in the given sequence.
    ///
    ///     let sequence = [2, 6, 0, 8, 1, 3, 1]
    ///     let subsequence = findLis(in: sequence) // [0, 1, 3]
    ///
    /// The example sequence has two lises: `[2, 6, 8]` and `[0, 1, 3]`.
    /// Therefore, this method returns the smallest one.
    ///
    static func findLis(in sequence: Sequence) -> Subsequence {
        
        guard sequence.count > 1 else { return sequence }
        
        // Technically, this array contains the found lises of each length for the current step.
        // Lises will be ordered by the last element. The length of next lis is one longer.
        // In this case, the longest lis is the last one.
        //
        // Example: sequence = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7]
        // `lises` will be [[0], [0, 1], [0, 1, 3], [0, 1, 3, 7], [0, 2, 6, 9, 11]]
        //
        var lises: [Subsequence] = [[sequence.first!]]
        
        for element in sequence[1...] {
            
            var lowerBound = 0, upperBound = lises.count - 1
            var elementIsNotFound = true
            
            // The point of this algorithm is that we do know that `lises` are ordered by the last element.
            // Shift the boundaries to the first element that is bigger than the current one.
            // Use binary search which is the fastest.
            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                let middleElement = lises[middle].last!
                
                // If we find an equal element, then we already know for sure that no changes can be made.
                guard middleElement != element else { elementIsNotFound = false; break }
                
                if middleElement > element { upperBound = middle }
                else { lowerBound = middle + 1 }
            }
            guard elementIsNotFound else { continue }
            
            let index = lowerBound
            
            // If all elements are smaller, then we add a new lis.
            // If all elements are bigger, then we change the first lis.
            // In any other case, we change the selected lis.
            if index == lises.count - 1, element > lises[index].last! {
                lises.append(lises[index] + [element])
            } else if index == 0 {
                lises[0] = [element]
            } else {
                lises[index] = lises[index - 1] + [element]
            }
        }
        
        return lises.last!
    }
    
    
    // MARK: Init
    
    private init() {}
    
}
