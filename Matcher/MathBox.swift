import ModKit

/// A math box that consists of methods for working with numbers, sequences and so on.
/// This calculates the math basis for the formation of `TypifiedText`.
final class MathBox {
    
    typealias OptionalSequence = [Int?]
    typealias Subsequence = [Int]
    typealias Sequence = [Int]
    
    /// The math basis for the formation of `TypifiedText`.
    ///
    ///     let comparedText = "hola"
    ///     let exemplaryText = "Hello"
    ///
    ///     let basis = MathBox.calculateBasis(
    ///         for: comparedText,
    ///         relyingOn: exemplaryText
    ///     )
    ///
    ///     basis.exemplarySequence // [0, 1, 2, 3, 4]
    ///     basis.sequence          // [0, 4, 2, nil ]
    ///     basis.subsequence       // [0,    2      ]
    ///     basis.missingElements   // [   1,    3, 4]
    ///
    struct Basis {
        
        /// A sequence generating from `exemplaryText`.
        let exemplarySequence: Sequence
        
        /// A sequence generating from `comparedText` relying on `exemplaryText`.
        let sequence: OptionalSequence
        
        /// The longest increasing subsequence found in `sequence`.
        let subsequence: Subsequence
        
        /// Elements that are missing in `sequence`.
        let missingElements: Sequence
        
        init(_ exemplarySequence: Sequence, _ sequence: OptionalSequence, _ subsequence: Subsequence) {
            self.exemplarySequence = exemplarySequence
            self.subsequence = subsequence
            self.sequence = sequence
            missingElements = exemplarySequence.filter { !subsequence.contains($0) }
        }
        
    }
    
    
    // MARK: Calculate Basis
    
    /// Calculates the math basis for the formation of `TypifiedText`.
    ///
    ///     let comparedText = "hola"
    ///     let exemplaryText = "Hello"
    ///
    ///     let basis = MathBox.calculateBasis(
    ///         for: comparedText,
    ///         relyingOn: exemplaryText
    ///     )
    ///
    ///     basis.exemplarySequence // [0, 1, 2, 3, 4]
    ///     basis.sequence          // [0, 4, 2, nil ]
    ///     basis.subsequence       // [0,    2      ]
    ///     basis.missingElements   // [   1,    3, 4]
    ///
    /// - Note: Letter case does not affect the result.
    /// - Parameters:
    ///     - comparedText: A text we compare with `exemplaryText` and find the best set of matching chars.
    ///     - exemplaryText: A text we relying on when calculating `basis` for `comparedText`.
    ///
    /// - Returns: The math basis that has properties consisting of indexes of chars in `exemplaryText`.
    ///
    static func calculateBasis(for comparedText: String, relyingOn exemplaryText: String) -> Basis {
        
        let comparedText = comparedText.lowercased(), exemplaryText = exemplaryText.lowercased()
        let exemplarySequence: Sequence = Array(0..<exemplaryText.count)
        let sequence: OptionalSequence, subsequence: Sequence
        
        if exemplaryText == comparedText {
            subsequence = exemplarySequence
            sequence = exemplarySequence
        } else {
            // Find a common beginning(prefix) and ending(suffix) of the texts.
            let prefix = comparedText.commonPrefix(with: exemplaryText).count
            var partialExemplaryText = exemplaryText.dropFirst(prefix).toString
            var partialComparedText  = comparedText .dropFirst(prefix).toString
            
            let suffix = partialComparedText.commonSuffix(with: partialExemplaryText).count
            partialExemplaryText = partialExemplaryText.dropLast(suffix).toString
            partialComparedText  = partialComparedText .dropLast(suffix).toString
            
            // Perform the work of the algorithm.
            let rawSequences = generateRawSequences(for: partialComparedText, relyingOn: partialExemplaryText)
            let rawPairs = makeRawPairs(from: rawSequences)
            let (partialSequence, partialSubsequence) = pickBestPair(among: rawPairs)
            
            // Restore the missing common parts.
            let exemplaryPrefix = exemplarySequence.first(prefix)
            let exemplarySuffix = exemplarySequence.last(suffix)
            
            // Put everything together.
            sequence = exemplaryPrefix + partialSequence.map { $0.hasValue ? $0! + prefix : nil } + exemplarySuffix
            subsequence = exemplaryPrefix + partialSubsequence.map { $0 + prefix } + exemplarySuffix
        }
        
        return Basis(exemplarySequence, sequence, subsequence)
    }
    
    
    // MARK: Pick Best Pair
    
    /// Picks the best pair among the given pairs.
    ///
    /// It is important that the subsequences are only of one length, otherwise this method will not work correctly.
    /// The picking is made by the smallest sum of the subsequence.
    ///
    ///     let rawPairs = [
    ///         ([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///         ([nil, 1, 2, 4, 3], [1, 2, 3])
    ///     ]
    ///     let bestPair = pickBestPair(among: rawPairs)
    ///     // ([nil, 1, 2, 4, 3], [1, 2, 3])
    ///
    static func pickBestPair(among rawPairs: [(OptionalSequence, Subsequence)]) -> (OptionalSequence, Subsequence) {
        
        guard !rawPairs.isEmpty else { return (OptionalSequence(), Subsequence()) }
        guard rawPairs.count > 1 else { return rawPairs[0] }
        
        var bestPair = rawPairs[0]
        
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
    static func makeRawPairs(from rawSequences: [OptionalSequence]) -> [(OptionalSequence, Subsequence)] {
        
        var pairs = [(OptionalSequence, Subsequence)]()
        var maxCount = Int()
        
        for rawSequence in rawSequences {
            let sequence = rawSequence.compactMap { $0 }
            let subsequence = findLis(in: sequence)
            if subsequence.count >= maxCount {
                pairs.append( (rawSequence, subsequence) )
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
        
        let dict = extractCharPositions(from: exemplaryText)
        let comparedText = comparedText.lowercased()
        var rawSequences = [OptionalSequence]()
        var cache = [Character: [Int]]()
        
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
                    recursion(sequence + [element], index + 1)
                    cache[char]!.removeLast()
                }
            } else {
                recursion(sequence + [nil], index + 1)
            }
        }
        
        recursion([], 0)
        
        return rawSequences
    }
    
    
    // MARK: Count Common Chars
    
    /// Counts common chars between the given texts.
    ///
    ///     let text1 = "Abcde"
    ///     let text2 = "aDftb"
    ///     let count = countCommonChars(between: text1, and: text2) // 3
    ///
    /// - Note: Letter case does not affect the result.
    ///
    static func countCommonChars(between text1: String, and text2: String) -> Int {
        
        let dict1 = extractCharPositions(from: text1)
        let dict2 = extractCharPositions(from: text2)
        var count = Int()
        
        for (key1, value1) in dict1 {
            if let value2 = dict2[key1] {
                count += min(value1.count, value2.count)
            }
        }
        
        return count
    }

    
    // MARK: Extract Char Positions
    
    /// Decomposes the given text into chars and indexes where they are placed.
    ///
    ///     let text = "Robot"
    ///     let dict = extractCharPositions(from: text)
    ///     // ["r": [0], "o": [1, 3], "b": [2], "t": [4]]
    ///
    /// - Note: Letter case does not affect the result.
    /// - Returns: A dictionary where each char keeps its own indexes.
    /// - Complexity: O(*n*), where *n* is the length of the text.
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
    /// This method returns the smallest one, that is `[0, 1, 3]`.
    /// - Returns: The longest increasing subsequence of the sequence.
    /// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
    ///
    static func findLis(in sequence: Sequence) -> Subsequence {
        
        guard sequence.count > 1 else { return sequence }
        
        // The array contains the found lises of each length for the current step.
        // Lises are ordered by the last element. The length of next lis is one longer.
        // Therefore, the longest lis is the last one.
        //
        // Example: sequence = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7]
        // At the last step, lises will be [[0], [0, 1], [0, 1, 3], [0, 1, 3, 7], [0, 2, 6, 9, 11]]
        var lises: [Subsequence] = [[sequence.first!]]
        
        for element in sequence[1...] {
            
            var lowerBound = 0, upperBound = lises.count - 1
            var index: Int { lowerBound }
            
            // Lises are ordered by the last element.
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


extension MathBox.Basis: Equatable {
    
    init(exemplarySequence: MathBox.Sequence, sequence: MathBox.OptionalSequence, subsequence: MathBox.Subsequence) {
        self.init(exemplarySequence, sequence, subsequence)
    }
    
    static func == (lhs: MathBox.Basis, rhs: MathBox.Basis) -> Bool {
        if lhs.exemplarySequence == rhs.exemplarySequence,
           lhs.subsequence == rhs.subsequence,
           lhs.sequence == rhs.sequence {
            return true
        }
        return false
    }
    
}
