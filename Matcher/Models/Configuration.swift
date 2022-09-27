/// A configuration that [typified text](TypifiedText) should conform to.
struct Configuration {
    
    /// The kind of action to be applied to the letter cases of the typified text.
    enum LetterCaseAction {
        
        /// Letter cases will not be changed, but there will be a mistake if letter cases do not match.
        case doNotChange
        
        /// Letter cases will be leaded to the given kind. There will not be a mistake if letter cases do not match.
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
    
    /// The action to be applied to the letter cases of the typified text.
    ///
    /// Kinds of action:
    ///
    /// - **doNotChange**: Letter cases will not be changed. There is a mistake if letter cases do not match.
    ///
    /// + **leadTo(Kind)**: Letter cases will be leaded to the given kind. There is no mistake if letter cases do not match.
    ///     - **capitalized**: The writing of a word with its first letter in uppercase and the remaining letters in lowercase.
    ///     - **uppercase**: The writing of a word in capital letters.
    ///     - **lowercase**: The writing of a word in small letters.
    ///
    /// - **nil**: Letter cases will not be changed. There is no mistake if letter cases do not match.
    ///
    var letterCaseAction: LetterCaseAction?
    
}
