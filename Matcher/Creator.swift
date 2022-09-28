import ModKit

/// A creator that forms the `TypifiedText` based on `MathBox`.
final class Creator {
    
    // MARK: Check for Exact Compliance
    
    /// Checks for exact compliance with the given configuration.
    ///
    /// In contrast to the quick compliance, to check for the exact compliance this method needs an argument of Basis type.
    /// Which means, checking happens only after complex calculations, but the compliance will be accurate.
    ///
    /// - Note: This method checks for the presence or absence of chars and for their order.
    /// - Returns: `true` if `basis` meets all the conditions; otherwise, `false`.
    ///
    static func checkForExactCompliance(for basis: MathBox.Basis, with configuration: Configuration) -> Bool {
        
        guard !basis.subsequence.isEmpty else { return false }
        
        let exemplaryLength = basis.exemplarySequence.count
        if let requiredCount = configuration.requiredQuantityOfMatchingChars?.calculate(for: exemplaryLength) {
            let countOfMatchingChars = basis.subsequence.count
            guard requiredCount <= countOfMatchingChars else { return false }
        }
        
        let comparedLength = basis.sequence.count
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.calculate(for: comparedLength) {
            let countOfWrongChars = basis.sequence.count - basis.subsequence.count
            guard countOfWrongChars <= acceptableCount else { return false }
        }
        
        return true
    }
    
    
    // MARK: Check for Quick Compliance
    
    /// Checks for quick compliance with the given configuration.
    ///
    /// This method finds max possible compliance, which means the compliance will be inaccurate.
    /// It allows you to find out in advance whether you need to do any complex calculations.
    ///
    /// For instance, conditionally, the quick compliance is 70% when in fact the exact compliance is 50%.
    /// But it cannot be that the quick compliance is 50% and the exact compliance is 70%.
    ///
    /// - Note: This method only checks for the presence or absence of chars, but not for their order.
    /// - Returns: `true` if `comparedText` possibly meets all the conditions; otherwise, `false`.
    ///
    static func checkForQuickCompliance(for comparedText: String, relyingOn exemplaryText: String, with configuration: Configuration) -> Bool {
        
        let countOfCommonChars = MathBox.countCommonChars(between: comparedText, and: exemplaryText)
        
        guard countOfCommonChars > 0 else { return false }
        
        if let requiredCount = configuration.requiredQuantityOfMatchingChars?.calculate(for: exemplaryText.count) {
            guard requiredCount <= countOfCommonChars else { return false }
        }
        
        if let acceptableCount = configuration.acceptableQuantityOfWrongChars?.calculate(for: comparedText.count) {
            let countOfWrongChars = comparedText.count - countOfCommonChars
            guard countOfWrongChars <= acceptableCount else { return false }
        }
        
        return true
    }
    
    
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
