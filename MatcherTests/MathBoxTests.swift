import XCTest
@testable import Matcher

class MathBoxTests: XCTestCase {
    
    typealias OptionalSequence = MathBox.OptionalSequence
    typealias Subsequence = MathBox.Subsequence
    typealias Sequence = MathBox.Sequence
    
    // MARK: Calculate Basis
    
    func testCalculateBasis() -> Void {
        
        typealias Basis = MathBox.Basis
        
        var comparedText = String()
        var accurateText = String()
        var basis: Basis {
            MathBox.calculateBasis(for: comparedText, relyingOn: accurateText)
        }
        
        XCTAssertEqual(basis, Basis([], [], []))
        
        comparedText = ""; accurateText = "ab"
        XCTAssertEqual(basis, Basis(accurateSequence: [0, 1], sequence: [], subsequence: []))
        
        comparedText = "ab"; accurateText = ""
        XCTAssertEqual(basis, Basis(accurateSequence: [], sequence: [nil, nil], subsequence: []))
        
        comparedText = "ab"; accurateText = "ab"
        XCTAssertEqual(basis, Basis(accurateSequence: [0, 1], sequence: [0, 1], subsequence: [0, 1]))
        
        comparedText = "ab"; accurateText = "cd"
        XCTAssertEqual(basis, Basis(accurateSequence: [0, 1], sequence: [nil, nil], subsequence: []))
        
        comparedText = "Ab"; accurateText = "aB"
        XCTAssertEqual(basis, Basis(accurateSequence: [0, 1], sequence: [0, 1], subsequence: [0, 1]))
            
        comparedText = "bac"; accurateText = "abc"
        XCTAssertEqual(basis, Basis(
            accurateSequence: [0, 1, 2],
            sequence:         [1, 0, 2],
            subsequence:      [   0, 2]
        ))
        
        comparedText = "3a1cb2"; accurateText = "abc123"
        XCTAssertEqual(basis, Basis(
            accurateSequence: [0, 1, 2, 3, 4, 5],
            sequence:         [5, 0, 3, 2, 1, 4],
            subsequence:      [   0,       1, 4]
        ))
        
        comparedText = "abc"; accurateText = "AaBb"
        XCTAssertEqual(basis, Basis(
            accurateSequence: [0, 1, 2, 3],
            sequence:         [0, 2, nil ],
            subsequence:      [0, 2      ]
        ))
        
        comparedText = "aaaa1bbbb"; accurateText = "aaaa2bbbb"
        XCTAssertEqual(basis, Basis(
            accurateSequence: [0, 1, 2, 3,  4,  5, 6, 7, 8],
            sequence:         [0, 1, 2, 3, nil, 5, 6, 7, 8],
            subsequence:      [0, 1, 2, 3,      5, 6, 7, 8]
        ))
        
        comparedText = "abbc"; accurateText = "abbbc"
        XCTAssertEqual(basis, Basis(
            accurateSequence: [0, 1, 2, 3, 4],
            sequence:         [0, 1, 2,    4],
            subsequence:      [0, 1, 2,    4]
        ))
        
    }
    
    
    // MARK: Pick Best Pair
    
    func testPickBestPair() -> Void {
        
        var rawPairs = [Pair]()
        var bestPair: Pair {
            let rawPairs = rawPairs.map { ($0.sequence, $0.subsequence) }
            let pair = MathBox.pickBestPair(among: rawPairs)
            return Pair(pair)
        }
        
        XCTAssertEqual(bestPair, Pair())
        
        rawPairs = [
            Pair(sequence: [0, 1, 2], subsequence: [0, 1, 2])
        ]
        XCTAssertEqual(bestPair, rawPairs[0])
        
        rawPairs = [
            Pair(sequence: [1, 4, 2], subsequence: [1, 2]),
            Pair(sequence: [1, 4, 3], subsequence: [1, 3])
        ]
        XCTAssertEqual(bestPair, rawPairs[0])
        
        rawPairs = [
            Pair(sequence: [nil, 1], subsequence: [1]),
            Pair(sequence: [nil, 2], subsequence: [2])
        ]
        XCTAssertEqual(bestPair, rawPairs[0])
        
        rawPairs = [
            Pair(sequence: [nil, 1, 5, 6], subsequence: [1, 5, 6]),
            Pair(sequence: [nil, 2, 4, 5], subsequence: [2, 4, 5]),
            Pair(sequence: [nil, 0, 2, 7], subsequence: [0, 2, 7]),
            Pair(sequence: [nil, 2, 3, 5], subsequence: [2, 3, 5])
        ]
        XCTAssertEqual(bestPair, rawPairs[2])
        
    }
    
    
    // MARK: Make Raw Pairs
    
    func testMakeRawPairs() -> Void {
        
        var rawSequences = [OptionalSequence]()
        var rawPairs: [Pair] {
            MathBox.makeRawPairs(from: rawSequences).map { Pair($0) }
        }
        
        XCTAssertEqual(rawPairs, [])
        
        rawSequences = [ [0, 1, 2] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: rawSequences[0], subsequence: [0, 1, 2])
        ])
        
        rawSequences = [ [0, 2, 1], [0, 2, 3] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: rawSequences[1], subsequence: [0, 2, 3])
        ])
        
        rawSequences = [ [nil] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: rawSequences[0], subsequence: [])
        ])
        
        rawSequences = [ [1, nil, 2], [1, nil, 3] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: rawSequences[0], subsequence: [1, 2]),
            Pair(sequence: rawSequences[1], subsequence: [1, 3])
        ])
        
        rawSequences = [ [nil, 2, 0, 4, nil], [nil, 2, 3, 4, nil] ]
        XCTAssertEqual(rawPairs, [
            Pair(sequence: rawSequences[1], subsequence: [2, 3, 4])
        ])
        
    }
    
    
    // MARK: Generate Raw Sequences
    
    func testGenerateRawSequences() -> Void {
        
        var comparedText = String()
        var accurateText = String()
        var rawSequences: [OptionalSequence] {
            MathBox.generateRawSequences(for: comparedText, relyingOn: accurateText)
        }
        
        XCTAssertEqual(rawSequences, [[]])
        
        comparedText = ""; accurateText = "abc"
        XCTAssertEqual(rawSequences, [[]])
        
        comparedText = "abc"; accurateText = ""
        XCTAssertEqual(rawSequences, [ [nil, nil, nil] ])
        
        comparedText = "abc"; accurateText = "def"
        XCTAssertEqual(rawSequences, [ [nil, nil, nil] ])
        
        comparedText = "abc"; accurateText = "abc"
        XCTAssertEqual(rawSequences, [ [0, 1, 2] ])
        
        comparedText = "Abc"; accurateText = "aBc"
        XCTAssertEqual(rawSequences, [ [0, 1, 2] ])
        
        comparedText = "aa"; accurateText = "aa"
        XCTAssertEqual(rawSequences, [ [0, 0], [0, 1], [1, 1] ])
        
        comparedText = "abcd"; accurateText = "dcba"
        XCTAssertEqual(rawSequences, [ [3, 2, 1, 0] ])
        
        comparedText = "abac"; accurateText = "caba"
        XCTAssertEqual(rawSequences, [ [1, 2, 1, 0], [1, 2, 3, 0], [3, 2, 3, 0] ])
        
    }
    
    
    // MARK: Count Common Chars
    
    func testCountCommonChars() -> Void {
        
        var text1 = String()
        var text2 = String()
        var count: Int {
            MathBox.countCommonChars(between: text1, and: text2)
        }
        
        XCTAssertEqual(count, 0)
        
        text1 = ""; text2 = "abc"
        XCTAssertEqual(count, 0)
        
        text1 = "abc"; text2 = ""
        XCTAssertEqual(count, 0)
        
        text1 = "abc"; text2 = "abc"
        XCTAssertEqual(count, 3)
        
        text1 = "Abc"; text2 = "aBc"
        XCTAssertEqual(count, 3)
        
        text1 = "abc"; text2 = "cba"
        XCTAssertEqual(count, 3)
        
        text1 = "Ab$c!"; text2 = "Ba$C?"
        XCTAssertEqual(count, 4)
        
        text1 = "#$%"; text2 = "$@#"
        XCTAssertEqual(count, 2)
        
        text1 = "AbAC"; text2 = "acBA"
        XCTAssertEqual(count, 4)
        
    }
    

    // MARK: Extract Char Positions
    
    func testExtractCharPositions() -> Void {
        
        var text = String()
        var dict: [Character: [Int]] {
            MathBox.extractCharPositions(from: text)
        }
        
        XCTAssertEqual(dict, [:])
        
        text = "abc"
        XCTAssertEqual(dict, ["a": [0], "b": [1], "c": [2]])
        
        text = "AbcaBC"
        XCTAssertEqual(dict, ["a": [0, 3], "b": [1, 4], "c": [2, 5]])
        
        text = "1!,@1"
        XCTAssertEqual(dict, ["1": [0, 4], "!": [1], ",": [2], "@": [3]])
        
    }
    
    
    // MARK: Find Lis
    
    func testFindLis() -> Void {
        
        var sequence = Sequence()
        var subsequence: Subsequence { MathBox.findLis(in: sequence) }
        
        XCTAssertEqual(subsequence, [])

        sequence = [1]
        XCTAssertEqual(subsequence, [1])

        sequence = [1, 0]
        XCTAssertEqual(subsequence, [0])

        sequence = [1, 0, 2, 1, 3]
        XCTAssertEqual(subsequence, [0, 1, 3])
        
        sequence = [2, 6, 0, 8, 1, 3, 1]
        XCTAssertEqual(subsequence, [0, 1, 3])
        
    }
    
    
    // MARK: Helpers
    
    private struct Pair: Equatable {
        let sequence: OptionalSequence
        let subsequence: Subsequence
        init(sequence: OptionalSequence, subsequence: Subsequence) {
            self.sequence = sequence; self.subsequence = subsequence
        }
        init(_ pair: (OptionalSequence, Subsequence)) {
            sequence = pair.0; subsequence = pair.1
        }
        init() { sequence = []; subsequence = [] }
        static func == (lhs: Self, rhs: Self) -> Bool {
            if lhs.sequence == rhs.sequence, lhs.subsequence == rhs.subsequence {
                return true
            } else { return false }
        }
    }
    
}
