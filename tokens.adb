pragma Ada_2012;
with Ada.Characters.Handling; use Ada.Characters.Handling;

package body tokens is

   -----------------
   -- is_valid_id --
   -----------------

   function is_valid_id (l: in lexeme) return boolean is
   begin
      return Is_Letter(to_string(l)(1));
   end is_valid_id;

   ----------
   -- make --
   ----------

   function make (tt: in token_type; l: in lexeme; row_num, col_num: in positive) return token is
      tok : token;
   begin
      tok.tt := tt;
      tok.l := l;
      tok.row_num := row_num;
      tok.col_num := col_num;
      return tok;
   end make;

   --------------------
   -- get_token_type --
   --------------------

   function get_token_type (tok: in token) return token_type is
   begin
      return tok.tt;
   end get_token_type;

   ----------------
   -- get_lexeme --
   ----------------

   function get_lexeme (tok: in token) return lexeme is
   begin
      return tok.l;
   end get_lexeme;

   -----------------
   -- get_row_num --
   -----------------

   function get_row_num (tok: in token) return positive is
   begin
      return tok.row_num;
   end get_row_num;

   -----------------
   -- get_col_num --
   -----------------

   function get_col_num (tok: in token) return positive is
   begin
      return tok.col_num;
   end get_col_num;

   -------------------
   -- lexeme_length --
   -------------------

   function lexeme_length (l: in lexeme) return positive is
   begin
      return l.size;
   end lexeme_length;

   ---------------
   -- to_string --
   ---------------

   function to_string (l: in lexeme) return string is
   begin
      return l.str;
   end to_string;

   ---------
   -- "=" --
   ---------

   function "=" (l: in lexeme; s: in string) return boolean is
   begin
      return l.str = s;
   end "=";

   ----------
   -- make --
   ----------

   function make (s: in string) return lexeme is
      lex : lexeme;
   begin
      lex.str(1..s'Length) := s;
      lex.size := s'Length;
      return lex;
   end make;

end tokens;
