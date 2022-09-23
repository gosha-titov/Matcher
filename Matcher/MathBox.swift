import ModKit

typealias OptionalSequence = [Int?]
typealias Subsequence = [Int]
typealias Sequence = [Int]


final class MathBox {
    
    // MARK: Methods
    
    /// Finds the longest increasing subsequence in the given sequence.
    ///
    ///     let sequence = [2, 6, 0, 8, 1, 3, 1]
    ///     let subsequence = findLis(in: sequence) // [0, 1, 3]
    ///
    /// The example sequence has two lises: `[2, 6, 8]` and `[0, 1, 3]`.
    /// Therefore, this method chooses the smallest one.
    ///
    static func findLis(in sequence: Sequence) -> Subsequence {
        
        func chooseBest(_ first: Sequence, _ second: Sequence) -> Sequence {
            let length1 = first.count, length2 = second.count
            let firstIsBetter = (length1 > length2) || (length1 == length2) && (first.last! < second.last!)
            return firstIsBetter ? first : second
        }
        
        guard sequence.count > 1 else { return sequence }
        
        var lises = [Subsequence]()
        var resultLis = Subsequence()
        
        for current in sequence.enumerated() {
            var bestLis = Subsequence()
            for previous in sequence[..<current.offset].enumerated().reversed()
            where current.element > previous.element {
                let previousLis = lises[previous.offset]
                bestLis = chooseBest(bestLis, previousLis)
            }
            bestLis.append(current.element)
            lises.append(bestLis)
            resultLis = chooseBest(resultLis, bestLis)
        }
        
        return resultLis
    }
    
    
    // MARK: Init
    
    private init() {}
    
}
