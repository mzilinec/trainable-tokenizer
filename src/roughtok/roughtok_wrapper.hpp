#ifndef INCLUDE_GUARD_ROUGHTOK_WRAPPER
#define INCLUDE_GUARD_ROUGHTOK_WRAPPER

#include <string>
#include <istream>

namespace trtok {

/* My own coding of the rough lexer token types. This removes a dependency
 * on Quex's native token type ids and makes the application more robust
 * and more easily modified. */
enum rough_token_id {
    TERMINATION_ID,
    TOKEN_PIECE_ID,
    MAY_BREAK_SENTENCE_ID,
    MAY_SPLIT_ID,
    MAY_JOIN_ID,
    WHITESPACE_ID,
};

/* My stripped down version of a rough token as reported by Quex. I use my
 * own data type so my code can rely on definitions which aren't generated during
 * runtime by Quex. If type_id == TOKEN_PIECE, the text member holds a UTF-8
 * STL string.*/
struct rough_token_t {
    rough_token_id type_id;
    std::string text;
    int n_newlines;
};

/* An interface to the wrapper of the generated lexer. This definition lets
 * me access the generated rough lexers using the same type signature thanks
 * to polymorphism. */
class IRoughLexerWrapper {
public:
    // Reconstructs the lexer and points to a new source of data without
    // having to call the factory function.
    virtual void setup(std::istream *in, char const *encoding) = 0;
    
    // Resets the lexer's state.
    virtual void reset() = 0;

    // Returns the next token generated by the input. Undefined behaviour
    // after sending the first token with type_id == TERMINATION.
    virtual rough_token_t receive() = 0;
};

}

#endif
