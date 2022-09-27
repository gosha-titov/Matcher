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
    
    enum LetterCase {
        case correct, wrong
    }
    
    
    let value: Character
    var type: CharType?
    var letterCase: LetterCase?
    
    
    init(_ value: Character, type: CharType? = nil, letterCase: LetterCase? = nil) {
        self.value = value; self.type = type; self.letterCase = letterCase
    }
    
    init() { value = " " }
    
}
