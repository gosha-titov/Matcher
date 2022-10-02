import XCTest
@testable import Matcher

class CreatorTests: XCTestCase {
    
    // MARK: Form Typified Text
    
    func testFormTypifiedText() -> Void {
        
        var comparedText = String()
        var accurateText = String()
        var configuration = Configuration()
        var typifiedText: TypifiedText {
            Creator.formTypifiedText(from: comparedText, relyingOn: accurateText, with: configuration)
        }
        
        XCTAssertEqual(typifiedText, [])
        
        comparedText = "abc"; accurateText = ""
        XCTAssertEqual(typifiedText, [
            TypifiedChar("a", type: .extra),
            TypifiedChar("b", type: .extra),
            TypifiedChar("c", type: .extra)
        ])
        
        comparedText = ""; accurateText = "abc"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("a", type: .missing),
            TypifiedChar("b", type: .missing),
            TypifiedChar("c", type: .missing)
        ])
        
        comparedText = "def"; accurateText = "abc"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("d", type: .extra),
            TypifiedChar("e", type: .extra),
            TypifiedChar("f", type: .extra)
        ])
        
        comparedText = "cde"; accurateText = "abc"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("a", type: .missing),
            TypifiedChar("b", type: .missing),
            TypifiedChar("c", type: .correct),
            TypifiedChar("d", type: .extra  ),
            TypifiedChar("e", type: .extra  )
        ])
        
        configuration.letterCaseAction = .compare
        XCTAssertEqual(typifiedText, [
            TypifiedChar("a", type: .missing),
            TypifiedChar("b", type: .missing),
            TypifiedChar("c", type: .correct, letterCaseIsCorrect: true),
            TypifiedChar("d", type: .extra  ),
            TypifiedChar("e", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.capitalized)
        comparedText = "abc"; accurateText = "ABC"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("A", type: .correct),
            TypifiedChar("b", type: .correct),
            TypifiedChar("c", type: .correct)
        ])
        
        configuration.letterCaseAction = nil
        comparedText = "ba"; accurateText = "ab"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("b", type: .extra  ),
            TypifiedChar("a", type: .correct),
            TypifiedChar("b", type: .missing)
        ])
        
        comparedText = "hola"; accurateText = "hello"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("h", type: .correct),
            TypifiedChar("e", type: .missing),
            TypifiedChar("o", type: .extra  ),
            TypifiedChar("l", type: .correct),
            TypifiedChar("l", type: .missing),
            TypifiedChar("o", type: .missing),
            TypifiedChar("a", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.uppercase)
        configuration.requiredQuantityOfCorrectChars = .half
        configuration.acceptableQuantityOfWrongChars = .half
        comparedText = "1a2b"; accurateText = "1234"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("1", type: .correct),
            TypifiedChar("A", type: .extra  ),
            TypifiedChar("2", type: .correct),
            TypifiedChar("3", type: .missing),
            TypifiedChar("4", type: .missing),
            TypifiedChar("B", type: .extra  )
        ])
        
        comparedText = "1abc"; accurateText = "1234"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("1", type: .extra),
            TypifiedChar("A", type: .extra),
            TypifiedChar("B", type: .extra),
            TypifiedChar("C", type: .extra)
        ])
        
    }
    
    
    // MARK: Applying
    
    func testApplying() -> Void {
        
        var typifiedText = TypifiedText()
        var configuration = Configuration()
        var applyedTypifiedText: TypifiedText {
            Creator.applying(configuration, to: typifiedText)
        }
        
        XCTAssertEqual(applyedTypifiedText, [])
        
        typifiedText = [
            TypifiedChar("a", type: .correct),
            TypifiedChar("B", type: .missing),
            TypifiedChar("c", type: .extra  )
        ]
        
        XCTAssertEqual(applyedTypifiedText, typifiedText)
        
        configuration.letterCaseAction = .compare
        XCTAssertEqual(applyedTypifiedText, typifiedText)
        
        configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(applyedTypifiedText, [
            TypifiedChar("A", type: .correct),
            TypifiedChar("b", type: .missing),
            TypifiedChar("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.lowercase)
        XCTAssertEqual(applyedTypifiedText, [
            TypifiedChar("a", type: .correct),
            TypifiedChar("b", type: .missing),
            TypifiedChar("c", type: .extra  )
        ])
        
        configuration.letterCaseAction = .leadTo(.uppercase)
        XCTAssertEqual(applyedTypifiedText, [
            TypifiedChar("A", type: .correct),
            TypifiedChar("B", type: .missing),
            TypifiedChar("C", type: .extra  )
        ])
        
    }
    
    
    // MARK: Check for Compliance
    
    func testCheckForCompliance() -> Void {
        
        var comparedText = String()
        var accurateText = String()
        var configuration = Configuration()
        var quickCompliance: Bool {
            Creator.checkForQuickCompliance(for: comparedText, relyingOn: accurateText, to: configuration)
        }
        var exactCompliance: Bool {
            let basis = MathBox.calculateBasis(for: comparedText, relyingOn: accurateText)
            return Creator.checkForExactCompliance(for: basis, to: configuration)
        }
        
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        comparedText = "abc"; accurateText = ""
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        comparedText = ""; accurateText = "abc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        comparedText = "aaab"; accurateText = "bccc"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, true)
        
        configuration.requiredQuantityOfCorrectChars = .low
        comparedText = "aaab"; accurateText = "bccc"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, true)
        
        configuration.requiredQuantityOfCorrectChars = .low
        comparedText = "aaaaab"; accurateText = "bccccc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        configuration.requiredQuantityOfCorrectChars = .half
        comparedText = "aa12"; accurateText = "21cc"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, false)
        comparedText = "aa12"; accurateText = "12cc"
        XCTAssertEqual(exactCompliance, true)
        
        configuration.requiredQuantityOfCorrectChars = .half
        comparedText = "aaabb"; accurateText = "bbccc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        configuration.requiredQuantityOfCorrectChars = .high
        comparedText = "a123"; accurateText = "321c"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, false)
        comparedText = "a123"; accurateText = "123c"
        XCTAssertEqual(exactCompliance, true)
        
        configuration.requiredQuantityOfCorrectChars = .high
        comparedText = "aabbb"; accurateText = "bbbcc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        configuration.requiredQuantityOfCorrectChars = .all
        comparedText = "1234"; accurateText = "4132"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, false)
        comparedText = "1234"; accurateText = "1234"
        XCTAssertEqual(exactCompliance, true)
        
        configuration.requiredQuantityOfCorrectChars = .all
        comparedText = "abbbb"; accurateText = "bbbbc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        configuration.requiredQuantityOfCorrectChars = nil
        configuration.acceptableQuantityOfWrongChars = .zero
        comparedText = "4132"; accurateText = "1234"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, false)
        comparedText = "1234"; accurateText = "1234"
        XCTAssertEqual(exactCompliance, true)
        
        configuration.acceptableQuantityOfWrongChars = .zero
        comparedText = "abbbb"; accurateText = "bbbbc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        configuration.acceptableQuantityOfWrongChars = .low
        comparedText = "a321"; accurateText = "123c"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, false)
        comparedText = "a123"; accurateText = "123c"
        XCTAssertEqual(exactCompliance, true)
        
        configuration.acceptableQuantityOfWrongChars = .low
        comparedText = "aabbb"; accurateText = "bbbcc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        configuration.acceptableQuantityOfWrongChars = .half
        comparedText = "aa21"; accurateText = "12cc"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, false)
        comparedText = "aa12"; accurateText = "12cc"
        XCTAssertEqual(exactCompliance, true)
        
        configuration.acceptableQuantityOfWrongChars = .half
        comparedText = "aaaabb"; accurateText = "bbcccc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
        configuration.acceptableQuantityOfWrongChars = .high
        comparedText = "aaab"; accurateText = "bccc"
        XCTAssertEqual(quickCompliance, true)
        XCTAssertEqual(exactCompliance, true)
        
        configuration.acceptableQuantityOfWrongChars = .high
        comparedText = "aaaaaab"; accurateText = "bcccccc"
        XCTAssertEqual(quickCompliance, false)
        XCTAssertEqual(exactCompliance, false)
        
    }
    

    // MARK: Make Typified Text
    
    func testMakeTypifiedText() -> Void {
        
        var text = String()
        var type = TypifiedChar.CharType()
        var configuration = Configuration()
        var typifiedText: TypifiedText {
            Creator.makeTypifiedText(from: text, withCharTypeOf: type, with: configuration)
        }
        
        XCTAssertEqual(typifiedText, [])
        
        text = "abc"
        XCTAssertEqual(typifiedText, [
            TypifiedChar("a", type: type),
            TypifiedChar("b", type: type),
            TypifiedChar("c", type: type),
        ])
        
        text = "AbC"; type = .correct
        XCTAssertEqual(typifiedText, [
            TypifiedChar("A", type: type),
            TypifiedChar("b", type: type),
            TypifiedChar("C", type: type),
        ])
        
        text = "aBc"; configuration.letterCaseAction = .compare
        XCTAssertEqual(typifiedText, [
            TypifiedChar("a", type: type),
            TypifiedChar("B", type: type),
            TypifiedChar("c", type: type),
        ])
        
        text = "Abc"; configuration.letterCaseAction = .leadTo(.uppercase)
        XCTAssertEqual(typifiedText, [
            TypifiedChar("A", type: type),
            TypifiedChar("B", type: type),
            TypifiedChar("C", type: type),
        ])
        
        text = "ABc"; configuration.letterCaseAction = .leadTo(.lowercase)
        XCTAssertEqual(typifiedText, [
            TypifiedChar("a", type: type),
            TypifiedChar("b", type: type),
            TypifiedChar("c", type: type),
        ])
        
        text = "aBc"; configuration.letterCaseAction = .leadTo(.capitalized)
        XCTAssertEqual(typifiedText, [
            TypifiedChar("A", type: type),
            TypifiedChar("b", type: type),
            TypifiedChar("c", type: type),
        ])
        
    }

}
