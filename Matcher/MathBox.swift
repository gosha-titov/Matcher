import ModKit

typealias OptionalSequence = [Int?]
typealias Subsequence = [Int]
typealias Sequence = [Int]


final class MathBox {
    
    // MARK: Pick Best Pair
    
    /// Picks the best pair among the given pairs.
    ///
    ///     let rawPairs = [
    ///         ([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///         ([nil, 1, 2, 4, 3], [1, 2, 3])
    ///     ]
    ///     let bestPair = pickBestPair(among: rawPairs)
    ///     // ([nil, 1, 2, 4, 3], [1, 2, 3])
    ///
    /// - Note: The picking is made by the smallest lis sum.
    ///
    static func pickBestPair(among rawPairs: [(OptionalSequence, Subsequence)]) -> (OptionalSequence, Subsequence) {
        guard !rawPairs.isEmpty else { return (OptionalSequence(), Subsequence()) }
        var bestPair = rawPairs[0]
        guard rawPairs.count > 1 else { return bestPair }
        for rawPair in rawPairs[1...] {
            let rawLis = rawPair.1, bestLis = bestPair.1
            if rawLis.sum < bestLis.sum {
                bestPair = rawPair
            }
        }
        return bestPair
    }
    
    
    // MARK: Make Raw Pairs
    
    /// Makes raw pairs by finding lises for the given sequences.
    ///
    ///     let rawSequences = [
    ///         [nil, 1, 2, 4, 1], // lis: [1, 2, 4]
    ///         [nil, 1, 2, 4, 3], // lis: [1, 2, 3]
    ///         [nil, 3, 2, 4, 3]  // lis: [2, 3]
    ///     ]
    ///
    ///     let rawPairs = makeRawPairs(for: rawSequences)
    ///     /* [ ([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///          ([nil, 1, 2, 4, 3], [1, 2, 3]) ] */
    ///
    /// - Note: The result will contain pairs with the max lis length.
    /// - Returns: Pairs of sequence and its subsequence.
    ///
    static func makeRawPairs(for sequences: [OptionalSequence]) -> [(OptionalSequence, Subsequence)] {
        
        var maxCount = Int()
        var pairs = [(OptionalSequence, Subsequence)]()
        
        sequences.forEach {
            let sequence = $0.compactMap { $0 }
            let subsequence = findLis(in: sequence)
            if subsequence.count >= maxCount {
                pairs.append( ($0, subsequence) )
                maxCount = subsequence.count
            }
        }
        
        return pairs.filter { $0.1.count == maxCount }
    }
    
    
    // MARK: Generate Raw Sequences

    /// Generates all possible char placements for `comparedText` relying on `exemplaryText`.
    ///
    /// This method searchs for the placements of the same char in `exemplaryText` for each char in `comparedText`.
    ///
    /// The raw sequences are arranged in increasing order.
    /// The indexes of the same chars are arranged in non-decreasing order.
    ///
    ///     let comparedText = "gotob"
    ///     let exemplaryText = "robot"
    ///     let rawSequences = generateRawSequences(
    ///         for: comparedText,
    ///         relyingOn: exemplaryText
    ///     )
    ///     /* [[nil, 1, 4, 1, 2],
    ///         [nil, 1, 4, 3, 2],
    ///         [nil, 3, 4, 3, 2]] */
    ///
    /// - Returns: The sequences where elemens are indexes of chars in `exemplaryText`.
    ///
    static func generateRawSequences(for comparedText: String, relyingOn exemplaryText: String) -> [OptionalSequence] {
        
        let comparedText = comparedText.lowercased()
        var rawSequences = [OptionalSequence]()
        var cache = [Character: [Int]]()
        let dict = extractCharPositions(from: exemplaryText)
        
        func recursion(_ sequence: OptionalSequence, _ index: Int) -> Void {
            guard index < comparedText.count else {
                rawSequences.append(sequence)
                return
            }
            let char = comparedText[index]
            if let elements = dict[char] {
                for element in elements {
                    if let array = cache[char], let last = array.last {
                        guard element >= last else { continue }
                        cache[char]!.append(element)
                    } else {
                        cache[char] = [element]
                    }
                    var newSequence = sequence
                    newSequence.append(element)
                    recursion(newSequence, index + 1)
                    cache[char]!.removeLast()
                }
            } else {
                var newSequence = sequence
                newSequence.append(nil)
                recursion(newSequence, index + 1)
            }
        }
        
        recursion([], 0)
        
        return rawSequences
    }

    
    // MARK: Extract Char Positions
    
    /// Decomposes the given text into chars and indexes where they are placed.
    ///
    ///     let text = "Robot"
    ///     let dict = extractCharPositions(from: text)
    ///     // ["r": [0], "o": [1, 3], "b": [2], "t": [4]]
    ///
    /// Letter case does not affect the result.
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
        // lises will be [[0], [0, 1], [0, 1, 3], [0, 1, 3, 7], [0, 2, 6, 9, 11]]
        var lises: [Subsequence] = [[sequence.first!]]
        
        for element in sequence[1...] {
            
            var lowerBound = 0, upperBound = lises.count - 1
            var index: Int { lowerBound }
            
            // The point of this algorithm is that we do know that `lises` are ordered by the last element.
            // Shift the boundaries to the first element that is bigger than the current one.
            // Use binary search which is the fastest.
            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                let middleElement = lises[middle].last!
                if middleElement == element { lowerBound = middle; break }
                if middleElement > element  { upperBound = middle }
                else { lowerBound = middle + 1 }
            }
            
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
