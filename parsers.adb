pragma Ada_2012;
with lexical_analyzers; use lexical_analyzers;
with tokens; use tokens;
with ids; use ids;
with statements; use statements;
with boolean_expressions; use boolean_expressions;
with arithmetic_expressions; use arithmetic_expressions;
with iters; use iters;

package body parsers is

   ----------
   -- make --
   ----------

   function make (file_name: in string) return parser is
      p : parser;
   begin
      p.lex := make(file_name);
      return p;
   end make;

   -----------
   -- parse --
   -----------

   procedure parse (this: in out parser; prog: out program) is
      lex : lexical_analyzer;
      tok : token;
      function_name : lexeme;
      bk : block;

      function get_binary_expression(this: in out lexical_analyzer) return arithmetic_expression_access;
      function get_block(this : in out lexical_analyzer) return block;

      --get id--
      function get_id (this: in out lexical_analyzer) return id is
         tok_id : id;
      begin
         tok := get_lookahead_token(this);
         get_next_token(this, tok);
         tok_id := ids.make(to_string(get_lexeme(tok)));
         return tok_id;
      end get_id;

      --get literal--
      function get_literal (this: in out lexical_analyzer) return Integer is
         lit_integer : Integer;
      begin
         tok := get_lookahead_token(this);
         get_next_token(this, tok);
         lit_integer := Integer'Value(to_string(get_lexeme(tok)));
         return lit_integer;
      end get_literal;


      --get arithmetic expression--
      function get_arithmetic_expression(this: in out lexical_analyzer) return arithmetic_expression_access is
         ar_expr : arithmetic_expression_access;
      begin
         tok := get_lookahead_token(this);
         if get_token_type(tok) = ID_TOK then
            ar_expr := make(get_id(this));
         elsif get_token_type(tok) = LITERAL_INTEGER_TOK then
            ar_expr := make(get_literal(this));
         else
            ar_expr := get_binary_expression(this);
         end if;
         return ar_expr;
      end get_arithmetic_expression;

      --get binary expression--
      function get_binary_expression(this: in out lexical_analyzer) return arithmetic_expression_access is
         ar_op : arithmetic_operator;
         expr1 : arithmetic_expression_access;
         expr2 : arithmetic_expression_access;
         binary_expr : arithmetic_expression_access;
      begin
         tok := get_lookahead_token(this);
         get_next_token(this, tok);
         --arithmetic operator--
         if get_token_type(tok) = ADD_TOK then
            ar_op := ADD_OP;
            if get_token_type(tok) /= ADD_TOK then
               raise parse_exception with "+ expected at " &
               Positive'Image(get_row_num(tok)) & " and column " &
               Positive'Image(get_col_num(tok));
            end if;
         elsif get_token_type(tok) = SUB_TOK then
            ar_op := SUB_OP;
            if get_token_type(tok) /= SUB_TOK then
               raise parse_exception with "- expected at " &
               Positive'Image(get_row_num(tok)) & " and column " &
               Positive'Image(get_col_num(tok));
            end if;
         elsif get_token_type(tok) = MUL_TOK then
            ar_op := MUL_OP;
            if get_token_type(tok) /= MUL_TOK then
               raise parse_exception with "* expected at " &
               Positive'Image(get_row_num(tok)) & " and column " &
               Positive'Image(get_col_num(tok));
            end if;
         elsif get_token_type(tok) = DIV_TOK then
            ar_op := DIV_OP;
            if get_token_type(tok) /= DIV_TOK then
               raise parse_exception with "/ expected at " &
               Positive'Image(get_row_num(tok)) & " and column " &
               Positive'Image(get_col_num(tok));
            end if;
         elsif get_token_type(tok) = MOD_TOK then
            ar_op := MOD_OP;
            if get_token_type(tok) /= MOD_TOK then
               raise parse_exception with "% expected at " &
               Positive'Image(get_row_num(tok)) & " and column " &
               Positive'Image(get_col_num(tok));
            end if;
         elsif get_token_type(tok) = EXP_TOK then
            ar_op := EXP_OP;
            if get_token_type(tok) /= EXP_TOK then
               raise parse_exception with "^ expected at " &
               Positive'Image(get_row_num(tok)) & " and column " &
               Positive'Image(get_col_num(tok));
            end if;
         elsif get_token_type(tok) = REV_DIV_TOK then
            ar_op := REV_DIV_OP;
            if get_token_type(tok) /= REV_DIV_TOK then
               raise parse_exception with "\ expected at " &
               Positive'Image(get_row_num(tok)) & " and column " &
               Positive'Image(get_col_num(tok));
            end if;
         else
            raise parse_exception with "arithmetic operator expected at row " &
            Positive'Image(get_row_num(tok))  & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         expr1 := get_arithmetic_expression(this);
         expr2 := get_arithmetic_expression(this);
         binary_expr := arithmetic_expressions.make(ar_op, expr1, expr2);
         return binary_expr;
      end get_binary_expression;

      --boolean expression--
      function get_boolean_expression (this : in out lexical_analyzer) return boolean_expression is
         bool_result : boolean_expression;
         bool_op : relational_operator;
         bool_expr1 : arithmetic_expression_access;
         bool_expr2 : arithmetic_expression_access;
      begin
         tok := get_lookahead_token(this);
         get_next_token(this, tok);
         if get_token_type(tok) = EQ_TOK then
            bool_op := EQ_OP;
         elsif get_token_type(tok) = NE_TOK then
            bool_op := NE_OP;
         elsif get_token_type(tok) = GT_TOK then
            bool_op := GT_OP;
         elsif get_token_type(tok) = GE_TOK then
            bool_op := GE_OP;
         elsif get_token_type(tok) = LT_TOK then
            bool_op := LT_OP;
         elsif get_token_type(tok) = LE_TOK then
            bool_op := LE_OP;
         else
            raise parse_exception with "relational operator expected at row " &
                 Positive'Image(get_row_num(tok))  & " and column " & Positive'Image(get_col_num(tok));
         end if;
         bool_expr1 := get_arithmetic_expression(this);
         bool_expr2 := get_arithmetic_expression(this);
         bool_result := boolean_expressions.make(bool_op, bool_expr1, bool_expr2);
         return bool_result;
      end get_boolean_expression;

      --get if_statement--
      function get_if_statement(this : in out lexical_analyzer) return statement_access is
         if_s : statement_access;
         b_expr : boolean_expression;
         if_blk : block;
         else_blk : block;
      begin
         tok := get_lookahead_token(this);
         --match if token--
         get_next_token(this, tok);
         if get_token_type(tok) /= IF_TOK then
            raise parse_exception with "if expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         b_expr := get_boolean_expression(this);
         if_blk := get_block(this);
         --match else token--
         get_next_token(this, tok);
         if get_token_type(tok) /= ELSE_TOK then
            raise parse_exception with "else expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         else_blk := get_block(this);
         --match end token--
         get_next_token(this, tok);
         if get_token_type(tok) /= END_TOK then
            raise parse_exception with "end expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         if_s := make(b_expr, if_blk, else_blk);
         return if_s;
      end get_if_statement;

      --get while_statement--
      function get_while_statement(this : in out lexical_analyzer) return statement_access is
         while_s : statement_access;
         while_expr : boolean_expression;
         while_blk : block;
      begin
         tok := get_lookahead_token(this);
         --match while token--
         get_next_token(this, tok);
         if get_token_type(tok) /= WHILE_TOK then
            raise parse_exception with "while expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         while_expr := get_boolean_expression(this);
         while_blk := get_block(this);
         --match end token--
         get_next_token(this, tok);
         if get_token_type(tok) /= END_TOK then
            raise parse_exception with "end expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         while_s := make(while_expr, while_blk);
         return while_s;
      end get_while_statement;

      --get print_statement--
      function get_print_statement(this : in out lexical_analyzer) return statement_access is
         print_s : statement_access;
         print_expr : arithmetic_expression_access;
      begin
         tok := get_lookahead_token(this);
         --match print token--
         get_next_token(this, tok);
         if get_token_type(tok) /= PRINT_TOK then
            raise parse_exception with "print expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         --match left paren token--
         get_next_token(this, tok);
         if get_token_type(tok) /= LEFT_PAREN_TOK then
            raise parse_exception with "( expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         print_expr := get_arithmetic_expression(this);
         --match right paren token--
         get_next_token(this, tok);
         if get_token_type(tok) /= RIGHT_PAREN_TOK then
            raise parse_exception with ") expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         print_s := make(print_expr);
         return print_s;
      end get_print_statement;

      --get assignment_statement--
      function get_assignment_statement(this : in out lexical_analyzer) return statement_access is
         assignment_s : statement_access;
         assignment_id : id;
         assignment_expr : arithmetic_expression_access;
      begin
         assignment_id := get_id(this);
         tok := get_lookahead_token(this);
         --match assign token--
         get_next_token(this, tok);
         if get_token_type(tok) /= ASSIGN_TOK then
            raise parse_exception with "= expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         assignment_expr := get_arithmetic_expression(this);
         assignment_s := make(assignment_id, assignment_expr);
         return assignment_s;
      end get_assignment_statement;

      --get for_statement--
      function get_for_statement(this : in out lexical_analyzer) return statement_access is
         for_s : statement_access;
         for_id : id;
         for_expr1 : arithmetic_expression_access;
         for_expr2 : arithmetic_expression_access;
         for_iter : iter;
         for_block : block;
      begin
         tok := get_lookahead_token(this);
         --match for token--
         get_next_token(this, tok);
         if get_token_type(tok) /= FOR_TOK then
            raise parse_exception with "for expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         for_id := get_id(this);
         --match assign token--
         get_next_token(this, tok);
         if get_token_type(tok) /= ASSIGN_TOK then
            raise parse_exception with "= expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         for_expr1 := get_arithmetic_expression(this);
         --match colon token--
         get_next_token(this, tok);
         if get_token_type(tok) /= COLON_TOK then
            raise parse_exception with ": expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         for_expr2 := get_arithmetic_expression(this);
         for_block := get_block(this);
         --match end token--
         get_next_token(this, tok);
         if get_token_type(tok) /= END_TOK then
            raise parse_exception with "end expected at " &
            Positive'Image(get_row_num(tok)) & " and column " &
            Positive'Image(get_col_num(tok));
         end if;
         for_iter := iters.make(for_expr1, for_expr2);
         for_s := make(for_id, for_iter, for_block);
         return for_s;
      end get_for_statement;

      --statement--
      function get_statement(this : in out lexical_analyzer) return statement_access is
         s : statement_access;
      begin
         tok := get_lookahead_token(this);
         if get_token_type(tok) = IF_TOK then
            s := get_if_statement(this);
         elsif get_token_type(tok) = WHILE_TOK then
            s := get_while_statement(this);
         elsif get_token_type(tok) = PRINT_TOK then
            s := get_print_statement(this);
         elsif get_token_type(tok) = ID_TOK then
            s := get_assignment_statement(this);
         elsif get_token_type(tok) = FOR_TOK then
            s := get_for_statement(this);
         else
            raise parse_exception with "invalid statement --> " &
            to_string(get_lexeme(tok)) & " <-- " & "at row " &
            Positive'Image(get_row_num(tok))  &
            " and column " & Positive'Image(get_col_num(tok));
         end if;
         return s;
      end get_statement;

      --block--
      function get_block(this : in out lexical_analyzer) return block is
         blk : block;
         stmt : statement_access;
      begin
         tok := get_lookahead_token(this);
         while get_token_type(tok) = ID_TOK or
         get_token_type(tok) = IF_TOK or
         get_token_type(tok) = WHILE_TOK or
         get_token_type(tok) = FOR_TOK or
         get_token_type(tok) = PRINT_TOK loop
            stmt := get_statement(this);
            add_statement(blk, stmt);
            tok := get_lookahead_token(this);
         end loop;
         return blk;
      end get_block;

 -------------------------------------------------------------------------------------------------------------------------------
   begin
      lex := this.lex;
      tok := get_lookahead_token(lex);
      -- match function--
      get_next_token(lex, tok);
      if get_token_type(tok) /= FUNCTION_TOK then
         raise parse_exception with "function expected at row " &
         Positive'Image(get_row_num(tok)) & " and column " & Positive'Image(get_col_num(tok));
      end if;
      --match function id--
      get_next_token(lex, tok);
      function_name := get_lexeme(tok);
      if not is_valid_id(function_name) then
         raise parse_exception with "valid id expected at " &
         Positive'Image(get_row_num(tok)) & " and column " & Positive'Image(get_col_num(tok));
      end if;
      --match left paren--
      get_next_token(lex, tok);
      if get_token_type(tok) /= LEFT_PAREN_TOK then
         raise parse_exception with "( expected at " &
         Positive'Image(get_row_num(tok)) & " and column " & Positive'Image(get_col_num(tok));
      end if;
      --match right paren--
      get_next_token(lex, tok);
      if get_token_type(tok) /= RIGHT_PAREN_TOK then
         raise parse_exception with ") expected at " &
         Positive'Image(get_row_num(tok)) & " and column " & Positive'Image(get_col_num(tok));
      end if;
      --get block--
      bk := get_block(lex);
      --match end token--
      get_next_token(lex, tok);
      if get_token_type(tok) /= END_TOK then
         raise parse_exception with "end expected at " &
         Positive'Image(get_row_num(tok)) & " and column " & Positive'Image(get_col_num(tok));
      end if;
      ----
      if get_token_type(tok) = EOS_TOK then
         raise parse_exception with "garbage at end of file";
      end if;
      prog := programs.make(ids.make(to_string(function_name)), bk);

   end parse;
end parsers;
