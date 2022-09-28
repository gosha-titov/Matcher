import XCTest
@testable import Matcher

class CreatorTests: XCTestCase {

    func test123() {
        
        let text = Creator.formBaseTypifiedStr(from: "HeLlO", relyingOn: "Hello", with: configuration)
        text.forEach { print($0) }
        
    }

}
