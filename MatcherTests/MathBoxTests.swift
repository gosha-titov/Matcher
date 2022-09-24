import XCTest
@testable import Matcher

class MathBoxTests: XCTestCase {
    
    // MARK: Generate Raw Sequences
    
    func testGenerateRawSequences() -> Void {
        
        var comparedText = String()
        var exemplaryText = String()
        var rawSequences: [OptionalSequence] {
            MathBox.generateRawSequences(for: comparedText, relyingOn: exemplaryText)
        }
        
        XCTAssertEqual(rawSequences, [[]])
        
        comparedText = ""; exemplaryText = "abc"
        XCTAssertEqual(rawSequences, [[]])
        
        comparedText = "abc"; exemplaryText = ""
        XCTAssertEqual(rawSequences, [ [nil, nil, nil] ])
        
        comparedText = "abc"; exemplaryText = "def"
        XCTAssertEqual(rawSequences, [ [nil, nil, nil] ])
        
        comparedText = "abc"; exemplaryText = "abc"
        XCTAssertEqual(rawSequences, [ [0, 1, 2] ])
        
        comparedText = "Abc"; exemplaryText = "aBc"
        XCTAssertEqual(rawSequences, [ [0, 1, 2] ])
        
        comparedText = "aa"; exemplaryText = "aa"
        XCTAssertEqual(rawSequences, [ [0, 0], [0, 1], [1, 1] ])
        
        comparedText = "abcd"; exemplaryText = "dcba"
        XCTAssertEqual(rawSequences, [ [3, 2, 1, 0] ])
        
        comparedText = "abac"; exemplaryText = "caba"
        XCTAssertEqual(rawSequences, [ [1, 2, 1, 0], [1, 2, 3, 0], [3, 2, 3, 0] ])
        
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

}
