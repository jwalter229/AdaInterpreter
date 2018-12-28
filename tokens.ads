package tokens is

   invalid_identifier: exception;
       
   type lexeme is private;
    
   type token is private;
   
   function is_valid_id (l: in lexeme) return boolean;
   
   type token_type is (FUNCTION_TOK, LEFT_PAREN_TOK, RIGHT_PAREN_TOK, IF_TOK,
                       ITER_TOK, END_TOK, ELSE_TOK, WHILE_TOK, FOR_TOK, ID_TOK,
                       PRINT_TOK, GE_TOK, GT_TOK, COLON_TOK, LE_TOK, LT_TOK, 
                       EQ_TOK, NE_TOK, ADD_TOK, SUB_TOK, MUL_TOK, DIV_TOK, 
                       EXP_TOK, MOD_TOK, REV_DIV_TOK, ASSIGN_TOK, EOS_TOK, LITERAL_INTEGER_TOK);
   
   function make (tt: in token_type; l: in lexeme; row_num, col_num: in positive)
                  return token;
   
   function get_token_type (tok: in token) return token_type;
   
   function get_lexeme (tok: in token) return lexeme;
   
   function get_row_num (tok: in token) return positive;
   
   function get_col_num (tok: in token) return positive;
   
   function lexeme_length (l: in lexeme) return positive;
   
   function to_string (l: in lexeme) return string;
   
   function "=" (l: in lexeme; s: in string) return boolean;
   
   function make (s: in string) return lexeme;
   
private
   type token is record
      tt: token_type := EOS_TOK;
      l: lexeme;
      row_num: positive := 1;
      col_num: positive := 1;
   end record;
   
   LEXEME_STRING_SIZE: constant natural := 10;
   
   type lexeme is record
      str: string (1 .. LEXEME_STRING_SIZE) := (1 => 'x', others => ' ');
      size: positive := 1;
   end record;

end tokens;
