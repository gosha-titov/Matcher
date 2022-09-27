/// A `Character` that has a `Type`.
///
///     let typifiedChar = TypifiedChar("a",
///         type: .correct,
///         letterCase: .wrong
///     )
///
struct TypifiedChar {
    
    enum CharType {
        case correct, swapped, missing, extra
        case misspell(_ correctChar: Character)
    }
    
    
    let value: Character
    var type: CharType?
    var letterCaseIsCorrect: Bool?
    
    
    init(_ value: Character, type: CharType? = nil, letterCaseIsCorrect: Bool? = nil) {
        self.value = value; self.type = type; self.letterCaseIsCorrect = letterCaseIsCorrect
    }
    
    init() { value = " " }
    
}
