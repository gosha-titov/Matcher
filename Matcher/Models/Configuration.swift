import ModKit

/// A configuration that [typified text](TypifiedText) should conform to.
struct Configuration {
    
    // MARK: Required and Acceptable Quantities
    
    /// The quantity indicating the required number of correct chars.
    ///
    /// The typified text is considered incorrect if its count of matching chars is less than this quantity.
    /// If this quantity is `nil` then the check will not be performed.
    /// - Note: The required count of correct chars is counted relative to the exemplary text.
    ///
    var requiredQuantityOfCorrectChars: CharQuantity?
    
    /// The quantity indicating the acceptable number of wrong chars.
    ///
    /// The typified text is considered incorrect if its count of wrong chars is more than this quantity.
    /// If this quantity is `nil` then the check will not be performed.
    /// - Note: The acceptable count of wrong chars is counted relative to the compared text.
    ///
    var acceptableQuantityOfWrongChars: CharQuantity?
    
    /// The quantity indicating the number of some chars.
    enum CharQuantity {
        
        /// `all` = 100%, `high` = 75%, `half` = 50%, `low` = 25%, `zero` = 0%
        case all, high, half, low, zero
        case other(Double)
        
        /// Calculates `Integer` value for this coefficient.
        func calculate(for length: Int) -> Int {
            let coefficient: Double
            switch self {
            case .other(let value): coefficient = value.clamped(to: 0...1.0)
            case .all:  coefficient = 1.0
            case .high: coefficient = 0.75
            case .half: coefficient = 0.5
            case .low:  coefficient = 0.25
            case .zero: coefficient = 0.0
            }
            return (length.toDouble * coefficient).rounded().toInt
        }
    }
    
    
    // MARK: Letter Case Action
    
    /// The action to be applied to the letter cases of the typified text.
    ///
    /// Kinds of action:
    ///
    /// - **compare**: Letter cases will be compared, there is a mistake if letter cases do not match.
    ///
    /// + **leadTo(Kind)**: Letter cases will be leaded to the given kind. There is no mistake if letter cases do not match.
    ///     - **capitalized**: The writing of a word with its first letter in uppercase and the remaining letters in lowercase.
    ///     - **uppercase**: The writing of a word in capital letters.
    ///     - **lowercase**: The writing of a word in small letters.
    ///
    /// If this action is `nil` then letter cases will not be changed. There is no mistake if letter cases do not match.
    ///
    var letterCaseAction: LetterCaseAction?
    
    /// The kind of action to be applied to the letter cases of the typified text.
    enum LetterCaseAction: Equatable {
        
        /// Letter cases will be compared, there is a mistake if letter cases do not match.
        case compare
        
        /// Letter cases will be leaded to the given kind. There is no mistake if letter cases do not match.
        case leadTo(Kind)
        
        /// The kind of writing of a word.
        enum Kind {
            /// The writing of a word with its first letter in uppercase and the remaining letters in lowercase.
            ///
            ///     let word = "Capitalized"
            case capitalized
            
            /// The writing of a word in capital letters.
            ///
            ///     let word = "UPPERCASE"
            case uppercase
            
            /// The writing of a word in small letters.
            ///
            ///     let word = "lowercase"
            case lowercase
        }
        
    }
    
}
