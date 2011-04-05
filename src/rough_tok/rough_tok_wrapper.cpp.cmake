#include <istream>

#include "RoughLexer"

#include "rough_tok_wrapper.hpp"
#include "no_init_exception.hpp"


// Quex adds a value to all user-defined token types. We want to translate
// Quex's type ids into our type ids which includes moving the range Quex
// uses into a zero-based one (by substracting the offset of token ids).
// This value will be set by CMake to the same value sent to Quex so it
// won't be sabotaged by changes in the implementation of Quex.
#define TOKEN_ID_OFFSET @QUEX_TOKEN_ID_OFFSET@

namespace trtok {

class RoughLexerWrapper : public IRoughLexerWrapper {
public:
	RoughLexerWrapper(): m_lexer_p(0x0), m_token_p(0x0), m_in_p(0x0), m_do_reset(false) {
		type_id_table[QUEX_ROUGH_TOKEN_PIECE - TOKEN_ID_OFFSET] = TOKEN_PIECE_ID;
		type_id_table[QUEX_ROUGH_MAY_BREAK_SENTENCE - TOKEN_ID_OFFSET] = MAY_BREAK_SENTENCE_ID;
		type_id_table[QUEX_ROUGH_MAY_SPLIT - TOKEN_ID_OFFSET] = MAY_SPLIT_ID;
		type_id_table[QUEX_ROUGH_MAY_JOIN - TOKEN_ID_OFFSET] = MAY_JOIN_ID;
		type_id_table[QUEX_ROUGH_WHITESPACE - TOKEN_ID_OFFSET] = WHITESPACE_ID;
		type_id_table[QUEX_ROUGH_LINE_BREAK - TOKEN_ID_OFFSET] = LINE_BREAK_ID;
		type_id_table[QUEX_ROUGH_PARAGRAPH_BREAK - TOKEN_ID_OFFSET] = PARAGRAPH_BREAK_ID;
	}

	virtual void setup(std::istream *in_p, char const *encoding) {
		m_in_p = in_p;
		m_encoding = encoding;
		reset();
	}

	virtual void reset() {
		m_do_reset = true;
	}

	virtual rough_token_t receive() {
		if (m_lexer_p == 0x0) {
			if (m_in_p == 0x0) {
				throw no_init_exception("setup hasn't been called yet on this instance of RoughLexerWrapper.");
			}
			m_lexer_p = new quex::RoughLexer(m_in_p, m_encoding);
			m_do_reset = false;
		}
		else if (m_do_reset) {
			m_lexer_p->reset(m_in_p, m_encoding);
			m_token_p = 0x0;
			m_do_reset = false;
		}

		m_lexer_p->receive(&m_token_p);
		rough_token_t out_token;
		if (m_token_p->type_id() == QUEX_ROUGH_TERMINATION)
			out_token.type_id = TERMINATION_ID;
		else
			out_token.type_id = type_id_table[m_token_p->type_id() - TOKEN_ID_OFFSET];
		if (out_token.type_id == TOKEN_PIECE_ID)
			out_token.text = m_token_p->pretty_char_text();
		return out_token;
	}
private:
	quex::RoughLexer *m_lexer_p;
	quex::Token *m_token_p;
	std::istream *m_in_p;
	char const *m_encoding;
	bool m_do_reset;
	rough_token_id type_id_table[7];
};

/* A factory function which we will retrieve by way of dlopen() and family
 * and use it to construct an instance of the wrapper class. */
extern "C" IRoughLexerWrapper* make_quex_wrapper() {
	return new RoughLexerWrapper();
}

}
