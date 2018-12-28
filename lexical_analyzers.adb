pragma Ada_2012;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded;
with tokens; use tokens;
with Ada.Characters.Conversions; use Ada.Characters.Conversions;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Assertions;  use Ada.Assertions;
with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Containers; use Ada.Containers;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings; use Ada.Strings;

package body lexical_analyzers is

   ----------
   -- make --
   ----------

   function make (file_name: in string) return lexical_analyzer is
      lex : lexical_analyzer;
      Input_File : File_Type;
      lexem : lexeme;
      tok_type : token_type;
      line_number : Positive := 1;
      index : Positive := 1;
      lexeme_pos : Positive;
      i : Positive;
      S : String(1..200);
      lex_len : Positive;
      S_length : Natural;

      function skip_whitespace(index : in out Positive; line : in String) return Positive is
      begin
         while index < line'Length and line(index) = ' ' loop
            index := index + 1;
         end loop;
         return index;
      end skip_whitespace;


   begin
      --get line--
      Open(File => Input_File, Mode => Ada.Text_IO.In_File, Name => file_name);
      while not End_OF_File (Input_File) loop
         Get_Line(Input_File, S, S_length);
         declare
            line : String(1..S_length+1) := (others => ' ');
         begin
            line(1..S_length) := S(1..S_length);
            --process line--
            index := 1;
            index := skip_whitespace(index, line);
            while index < line'Length loop
               --get lexeme--
               lexeme_pos := index;
               while lexeme_pos < line'Length and line(lexeme_pos) /= ' ' loop
                  lexeme_pos := lexeme_pos + 1;
               end loop;
               lex_len := lexeme_pos - index;
               declare
                  lexeme_str : String(1..lex_len);
               begin
                  lexeme_str := line(index..lexeme_pos-1);
                  lexem := tokens.make(lexeme_str);

                  --get token--
                  if Is_Letter(lexeme_str(1)) then
                     if lexeme_str'Length = 1 and is_valid_id(lexem) then
                        tok_type := ID_TOK;
                     elsif lexeme_str = "if" then
                        tok_type := IF_TOK;
                     elsif lexeme_str = "function" then
                        tok_type := FUNCTION_TOK;
                     elsif lexeme_str = "end" then
                        tok_type := END_TOK;
                     elsif lexeme_str = "else" then
                        tok_type := ELSE_TOK;
                     elsif lexeme_str = "for" then
                        tok_type := FOR_TOK;
                     elsif lexeme_str = "while" then
                        tok_type := WHILE_TOK;
                     elsif lexeme_str = "print" then
                        tok_type := PRINT_TOK;
                     else
                        raise lexical_exception with "invalid lexeme -> " & lexeme_str &
                        " <- at row number" & Positive'Image(line_number) &
                        " and column" & Positive'Image(index);
                     end if;
                  elsif Is_Digit(lexeme_str(1)) then
                     i := 1;
                     while i < lex_len and Is_Digit(lexeme_str(i)) loop
                        i := i + 1;
                     end loop;
                     if i = lex_len then
                        tok_type := LITERAL_INTEGER_TOK;
                     else
                        raise lexical_exception with "invalid lexeme -> " & Positive'Image(i) &
                        " <- at row number" & Positive'Image(line_number) &
                        " and column " & Positive'Image(index);
                     end if;
                  elsif lexeme_str = "+" then
                     tok_type := ADD_TOK;
                  elsif lexeme_str = "-" then
                     tok_type := SUB_TOK;
                  elsif lexeme_str = "*" then
                     tok_type := MUL_TOK;
                  elsif lexeme_str = "/" then
                     tok_type := DIV_TOK;
                  elsif lexeme_str = "\" then
                     tok_type := REV_DIV_TOK;
                  elsif lexeme_str = "^" then
                     tok_type := EXP_TOK;
                  elsif lexeme_str = "%" then
                     tok_type := MOD_TOK;
                  elsif lexeme_str = "=" then
                     tok_type := ASSIGN_TOK;
                  elsif lexeme_str = "(" then
                     tok_type := LEFT_PAREN_TOK;
                  elsif lexeme_str = ")" then
                     tok_type := RIGHT_PAREN_TOK;
                  elsif lexeme_str = ">=" then
                     tok_type := GE_TOK;
                  elsif lexeme_str = ">" then
                     tok_type := GT_TOK;
                  elsif lexeme_str = "<=" then
                     tok_type := LE_TOK;
                  elsif lexeme_str = "<" then
                     tok_type := LT_TOK;
                  elsif lexeme_str = "==" then
                     tok_type := EQ_TOK;
                  elsif lexeme_str = "!=" then
                     tok_type := NE_TOK;
                  elsif lexeme_str = ":" then
                     tok_type := COLON_TOK;
                  else
                     raise lexical_exception with "invalid lexeme --> " & lexeme_str &
                     " <-- at row number " & Positive'Image(line_number) &
                     " and column " & Positive'Image(index);
                  end if;

                  lex.token_list.Append(tokens.make(tok_type, lexem, line_number, index));
                  index := index + lexeme_length(lexem);
                  index := skip_whitespace(index, line);

               end; --declare--
            end loop; --end process line--
            line_number := line_number + 1;
            end; --declare--
      end loop; --end get line--
      tok_type := EOS_TOK;
      lexem := tokens.make("EOS");
      lex.token_list.Append(tokens.make(tok_type, lexem, line_number + 1, 1));
      Close(Input_File);
      return lex;
   end make;

   --------------------
   -- get_next_token --
   --------------------

   procedure get_next_token (this: in out lexical_analyzer; tok: out token) is
   begin
      tok := this.token_list.First_Element;
      this.token_list.Delete_First;
   end get_next_token;

   -------------------------
   -- get_lookahead_token --
   -------------------------

   function get_lookahead_token (this: in lexical_analyzer) return token is
   begin
      return this.token_list.First_Element;
   end get_lookahead_token;

   ---------------------
   -- has_more_tokens --
   ---------------------

   function has_more_tokens (this: in lexical_analyzer) return boolean is
   begin
      return this.token_list.Length > 0;
   end has_more_tokens;

   -------------------------------------------------------
   -------------------------------------------------------
   -------------------------------------------------------
   procedure print_lex(this : in lexical_analyzer) is
      tokn : token;
      tok_t : token_type;
      lxm : lexeme;
      current : token_lists.Cursor := token_lists.First(this.token_list);
   begin
      while token_lists.Has_Element(current) loop
         tokn := token_lists.Element(current);
         tok_t := get_token_type(tokn);
         lxm := get_lexeme(tokn);
         Put_Line(to_string(lxm) & " " & Positive'Image(lexeme_length(lxm)));
         token_lists.Next(current);
      end loop;
   end print_lex;


end lexical_analyzers;
