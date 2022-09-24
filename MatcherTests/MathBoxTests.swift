import XCTest
@testable import Matcher

class MathBoxTests: XCTestCase {

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
