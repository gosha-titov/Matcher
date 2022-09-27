import ModKit

/// A creator that forms the `TypifiedText` based on `MathBox`.
final class Creator {
    
    // MARK: Make (One-Type) Typified Text
    
    /// Makes typified text where all chars are of the same type.
    ///
    ///     let configuration = Configuration()
    ///     configuration.letterCaseAction = .leadTo(.capitalized)
    ///
    ///     let text = "abc"
    ///     let typifiedText = Creator.makeTypifiedText(
    ///         from: text,
    ///         withCharTypeOf: .correct,
    ///         with: configuration
    ///     )
    ///     /*[TypifiedChar("A", type: .correct, letterCaseIsCorrect: true),
    ///        TypifiedChar("b", type: .correct, letterCaseIsCorrect: true),
    ///        TypifiedChar("c", type: .correct, letterCaseIsCorrect: true)]*/
    ///
    static func makeTypifiedText(from text: String, withCharTypeOf type: TypifiedChar.CharType, with configuration: Configuration) -> TypifiedText {
        
        var text = text
        var IsCorrect: Bool? = true
        
        if let action = configuration.letterCaseAction {
            switch action {
            case .doNotChange: IsCorrect = nil
            case .leadTo(let kind):
                switch kind {
                case .capitalized: text.capitalize()
                case .uppercase:   text.uppercase()
                case .lowercase:   text.lowercase()
                }
            }
        }
        
        return text.map { TypifiedChar($0, type: type, letterCaseIsCorrect: IsCorrect) }
    }
    
    
    // MARK: Init
    
    private init() {}
    
}
