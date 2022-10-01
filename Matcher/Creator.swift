import ModKit

/// A creator that forms the `TypifiedText` based on `MathBox`.
final class Creator {
    
    // MARK: Form Typified Text
    
    /// Forms typified text from the given compared and exempary texts with configuration.
    ///
    ///     let comparedText = "hola"
    ///     let exemplaryText = "Hello"
    ///
    ///     let configuration = Configuration()
    ///     configuration.letterCaseAction = .leadTo(.capitalized)
    ///
    ///     let typifiedText = Creator.formTypifiedText(
    ///         from: comparedText,
    ///         relyingOn: exemplaryText,
    ///         with: configuration
    ///     )
    ///     /*[TypifiedChar("H", type: .correct),
    ///        TypifiedChar("e", type: .missing),
    ///        TypifiedChar("o", type: .extra  ),
    ///        TypifiedChar("l", type: .correct),
    ///        TypifiedChar("l", type: .missing),
    ///        TypifiedChar("o", type: .missing),
    ///        TypifiedChar("a", type: .extra  )]*/
    ///
    /// Only three types of chars are used for forming: `.extra`, `.correct` and `.missing`.
    /// That is, the typified text needs to be processed by adding `.misspell` and `.swapped` chars.
    ///
    /// **The formation is performed if there is at least one correct char**; otherwise, it returns completely `.extra` or `missing` typified text.
    ///
    ///     let comparedText = "hi!"
    ///     let exemplaryText = "bye."
    ///     let typifiedText = Creator.formTypifiedText(
    ///         from: comparedText,
    ///         relyingOn: exemplaryText
    ///     )
    ///     /*[TypifiedChar("h", type: .extra),
    ///        TypifiedChar("i", type: .extra),
    ///        TypifiedChar("!", type: .extra)]*/
    ///
    /// - Important: The longer the texts, the harder work and, accordingly, the longer this method will be performed.
    /// So, don't give large texts, otherwise this method can be performed for dozens or even hundreds of seconds.
    /// Try to use the **requiredQuantityOfCorrectChars** and **acceptableQuantityOfWrongChars** properties of `configuration`,
    /// it helps to save time by pre-сhecking.
    ///
    /// - Note: If you take the correct and missing chars from the typified text in the order in which they stand, then you get the exemplary text.
    ///
    static func formTypifiedText(from comparedText: String, relyingOn exemplaryText: String, with configuration: Configuration = .init()) -> TypifiedText {
        
        var missingExemplaryTypifiedText: TypifiedText { makeTypifiedText(from: exemplaryText, withCharTypeOf: .missing, with: configuration) }
        var wrongComparedTypifiedText:    TypifiedText { makeTypifiedText(from: comparedText,  withCharTypeOf: .extra,   with: configuration) }
        
        guard !exemplaryText.isEmpty else { return wrongComparedTypifiedText }
        guard !comparedText .isEmpty else { return missingExemplaryTypifiedText }
        
        let quickCompliance = checkForQuickCompliance(for: comparedText, relyingOn: exemplaryText, to: configuration)
        guard quickCompliance else { return wrongComparedTypifiedText }
        
        let basis = MathBox.calculateBasis(for: comparedText, relyingOn: exemplaryText)
        
        let exactCompliance = checkForExactCompliance(for: basis, to: configuration)
        guard exactCompliance else { return wrongComparedTypifiedText }
        
        var typifiedText = wrongComparedTypifiedText
        
        typifiedText = addingCorrectChars(to: typifiedText, relyingOn: exemplaryText, basedOn: basis, with: configuration)
        typifiedText = addingMissingChars(to: typifiedText, relyingOn: exemplaryText, basedOn: basis)
        
        typifiedText = applying(configuration, to: typifiedText)
        
        return typifiedText
    }
    
    
    // MARK: Applying
    
    /// Returns a typified text with applied configuration.
    ///
    /// Аfter executing this method, the values, the types, the order and the count of typified chars will not be changed.
    /// Only parameters such as `letterCaseIsCorrect` can be changed.
    ///
    static func applying(_ configuration: Configuration, to typifiedText: TypifiedText) -> TypifiedText {
        
        var typifiedText = typifiedText
        
        if let action = configuration.letterCaseAction {
            switch action {
            case .doNotChange: break
            case .leadTo(let kind):
                var text = typifiedText.map { $0.value }.joined()
                let types = typifiedText.map { $0.type }
                switch kind {
                case .capitalized: text.capitalize()
                case .uppercase:   text.uppercase()
                case .lowercase:   text.lowercase()
                }
                typifiedText = zip(text, types).map { TypifiedChar($0.0, type: $0.1) }
            }
        }
        
        return typifiedText
    }
    
    
    // MARK: Adding Missing Char
    
    /// Returns a typified text with added missing chars.
    ///
    /// This method inserts missing chars after correct ones.
    /// The existing typified chars will not change in any way, but missing will be added.
    /// That is, the count of typified chars changes, which makes the basis no longer usable.
    ///
    ///  - Note: The order of typified chars is not changed before this method is called.
    ///
    static func addingMissingChars(to typifiedText: TypifiedText, relyingOn exemplaryText: String, basedOn basis: MathBox.Basis) -> TypifiedText {
        
        var typifiedText = typifiedText, subIndex = Int()
        var subElement: Int { basis.subsequence[subIndex] }
        var missingElements = basis.missingElements
        var insertingIndex = Int(), offset = Int()
        
        for (index, element) in basis.sequence.enumerated() where element == subElement {
            
            func insert(_ indexes: [Int]) -> Void {
                for index in indexes.reversed() {
                    let char = exemplaryText[index]
                    let typifiedChar = TypifiedChar(char, type: .missing)
                    typifiedText.insert(typifiedChar, at: insertingIndex)
                }
            }
            
            let insertions = missingElements.filter { $0 < subElement }
            missingElements.removeFirst(insertions.count)
            insert(insertions)
            
            offset += insertions.count
            insertingIndex = (index + 1) + offset
            subIndex += 1
            
            guard subIndex < basis.subsequence.count else {
                insert(missingElements); break
            }
        }
        
        return typifiedText
    }
    
    
    // MARK: Adding Correct Char
    
    /// Returns a typified text with added correct chars.
    ///
    /// This method looks for the elements of `basis.subsequence` in `basis.sequence`, when this happens we get the correct char.
    /// That is, the typified text must be made up of the compared text and be of `.extra` type.
    ///
    /// Аfter executing this method, the values and the count of typified chars and will not be changed, there will be no rearrangements of typified chars.
    /// Only some their types will be changed from `.extra` to `.correct`.
    ///
    /// - Note: The order of typified chars is not changed before this method is called.
    ///
    static func addingCorrectChars(to typifiedText: TypifiedText, relyingOn exemplaryText: String, basedOn basis: MathBox.Basis, with configuration: Configuration) -> TypifiedText {
        
        var typifiedText = typifiedText, subIndex = Int()
        var subElement: Int { basis.subsequence[subIndex] }
        
        for (index, element) in basis.sequence.enumerated() where element == subElement {
            var letterCaseIsCorrect: Bool?
            if let action = configuration.letterCaseAction, action == .doNotChange {
                letterCaseIsCorrect = exemplaryText[subElement] == typifiedText[index].value
            }
            typifiedText[index].letterCaseIsCorrect = letterCaseIsCorrect
            typifiedText[index].type = .correct
            subIndex += 1
            guard subIndex < basis.subsequence.count else { break }
        }
        
        return typifiedText
    }
    
    
    // MARK: Check for Exact Compliance
    
    /// Checks for exact compliance to the given configuration.
    ///
    /// In contrast to the quick compliance, to check for the exact compliance this method needs an argument of Basis type.
    /// Which means, checking happens only after complex calculations, but the compliance will be accurate.
    ///
    /// - Note: This method checks for the presence or absence of chars and for their order.
    /// - Returns: `true` if `basis` satisfies all the conditions; otherwise, `false`.
    ///
    static func checkForExactCompliance(for basis: MathBox.Basis, to configuration: Configuration) -> Bool {
        
        guard !basis.subsequence.isEmpty else { return false }
        
        let exemplaryLength = basis.exemplarySequence.count
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.calculate(for: exemplaryLength) {
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
    
    /// Checks for quick compliance to the given configuration.
    ///
    /// This method finds max possible compliance, which means the compliance will be inaccurate.
    /// It allows you to find out in advance whether you need to do any complex calculations.
    ///
    /// For instance, conditionally, the quick compliance is 70% when in fact the exact compliance is 50%.
    /// But it cannot be that the quick compliance is 50% and the exact compliance is 70%.
    ///
    /// - Note: This method only checks for the presence or absence of chars, but not for their order.
    /// - Returns: `true` if `comparedText` possibly satisfies all the conditions; otherwise, `false`.
    ///
    static func checkForQuickCompliance(for comparedText: String, relyingOn exemplaryText: String, to configuration: Configuration) -> Bool {
        
        let countOfCommonChars = MathBox.countCommonChars(between: comparedText, and: exemplaryText)
        
        guard countOfCommonChars > 0 else { return false }
        
        if let requiredCount = configuration.requiredQuantityOfCorrectChars?.calculate(for: exemplaryText.count) {
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
    ///     /*[TypifiedChar("A", type: .correct),
    ///        TypifiedChar("b", type: .correct),
    ///        TypifiedChar("c", type: .correct]*/
    ///
    static func makeTypifiedText(from text: String, withCharTypeOf type: TypifiedChar.CharType, with configuration: Configuration) -> TypifiedText {
        
        var text = text
        
        if let action = configuration.letterCaseAction {
            switch action {
            case .doNotChange: break
            case .leadTo(let kind):
                switch kind {
                case .capitalized: text.capitalize()
                case .uppercase:   text.uppercase()
                case .lowercase:   text.lowercase()
                }
            }
        }
        
        return text.map { TypifiedChar($0, type: type) }
    }
    
    
    // MARK: Init
    
    private init() {}
    
}
