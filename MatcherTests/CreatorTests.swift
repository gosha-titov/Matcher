import XCTest
@testable import Matcher
import ModKit

class CreatorTests: XCTestCase {

    func test123() {
        
        var configuration = Configuration()
        configuration.letterCaseAction = .leadTo(.capitalized)
        let text = Creator.formTypifiedText(from: "hola", relyingOn: "Hello", with: configuration)
        text.forEach { print($0) }
        
    }

}
