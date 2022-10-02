/// A `Character` that has a `Type`.
///
///     let typifiedChar = TypifiedChar("a",
///         type: .correct,
///         letterCase: .wrong
///     )
///
struct TypifiedChar {
    
    enum CharType: Equatable {
        case correct, swapped, missing, extra
        case misspell(_ correctChar: Character)
        
        init() { self = .extra }
    }
    
    
    let value: Character
    var type: CharType
    
    /// A Boolean value indicating whether the letter case is correct.
    ///
    ///     let accurateChar = Character("A")
    ///     let comparedChar = Character("a")
    ///
    ///     // typifiedChar.letterCaseIsCorrect is false
    ///
    var letterCaseIsCorrect: Bool?
    
    
    init(_ value: Character, type: CharType, letterCaseIsCorrect: Bool? = nil) {
        self.value = value; self.type = type; self.letterCaseIsCorrect = letterCaseIsCorrect
    }
    
}


extension TypifiedChar: Equatable {
    
    static func == (lhs: TypifiedChar, rhs: TypifiedChar) -> Bool {
        
        guard lhs.value == rhs.value, lhs.type == rhs.type,
              lhs.letterCaseIsCorrect == rhs.letterCaseIsCorrect
        else { return false }
        
        return true
    }
    
}
