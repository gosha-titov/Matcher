import XCTest
@testable import Matcher

class MathBoxTests: XCTestCase {

    
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
