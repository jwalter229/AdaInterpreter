pragma Ada_2012;
with memory; use memory;
with ids; use ids;
with arithmetic_expressions; use arithmetic_expressions;
with boolean_expressions; use boolean_expressions;
with iters; use iters;
with Ada.Text_IO; use Ada.Text_IO;
with tokens; use tokens;
with Ada.Assertions; use Ada.Assertions;

package body statements is

   -------------
   -- execute --
   -------------

   procedure execute (this: in statement) is
      i : Integer;
      ar_expr: arithmetic_expression_access;
      l :lexeme;
   begin
      case this.s_type is
         when ASSN_STMT =>
            memory.store(get_lexeme(this.var), evaluate(this.r_value.all));
         when IF_STMT =>
            if evaluate(this.if_expr) then
               execute(this.if_block);
            else
               execute(this.else_block);
            end if;
         when FOR_STMT => --incrementing loop--
            l := get_lexeme(this.loop_var);
            ar_expr := get_start_expr(this.loop_control);
            memory.store(l, evaluate(ar_expr.all));
            while memory.fetch(get_lexeme(this.loop_var)) <= evaluate(get_end_expr(this.loop_control).all) loop
               execute(this.for_body);
               i := memory.fetch(get_lexeme(this.loop_var));
               i := i + 1;
               memory.store(get_lexeme(this.loop_var), i);
            end loop;
         when WHILE_STMT =>
            while evaluate(this.while_expr) loop
               execute(this.while_body);
            end loop;
         when PRINT_STMT =>
            Put(Integer'Image(evaluate(this.print_expr.all)));
      end case;
   end execute;

   -------------------
   -- add_statement --
   -------------------

   procedure add_statement (this: in out block; stmt: in not null statement_access) is
   begin
      this.stmts.Append(stmt);
   end add_statement;

   -------------
   -- execute --
   -------------

   procedure execute (this: in block) is
      current : statement_list.Cursor := statement_list.First(this.stmts);
      s : statement_access;
   begin
      Assert(not this.stmts.Is_Empty);
      while statement_list.Has_Element(current) loop
         s := statement_list.Element(current);
         execute(s.all);
         statement_list.Next(current);
      end loop;
   end execute;

   ----------
   -- make --
   ----------

   function make (expr: in not null arithmetic_expression_access) return statement_access is
   stmt : statement_access;
   begin
      stmt := new statement(PRINT_STMT);
      stmt.all.print_expr := expr;
      return stmt;
   end make;

   ----------
   -- make --
   ----------

   function make (loop_var: in id; loop_control: in iter; bk: in block) return statement_access is
      stmt : statement_access;
   begin
      Assert(is_valid_id(get_lexeme(loop_var)));
      Assert(not bk.stmts.Is_Empty);
      stmt := new statement(FOR_STMT);
      stmt.all.loop_var := loop_var;
      stmt.all.loop_control := loop_control;
      stmt.all.for_body := bk;
      return stmt;
   end make;

   ----------
   -- make --
   ----------

   function make (expr: in boolean_expression; if_block, else_block: in block) return statement_access is
      stmt : statement_access;
   begin
      Assert(not if_block.stmts.Is_Empty);
      Assert(not else_block.stmts.Is_Empty);
      stmt := new statement(IF_STMT);
      stmt.all.if_expr := expr;
      stmt.all.if_block := if_block;
      stmt.all.else_block := else_block;
      return stmt;
   end make;

   ----------
   -- make --
   ----------

   function make (expr: in boolean_expression; bk: in block) return statement_access is
   stmt : statement_access;
   begin
      Assert(not bk.stmts.Is_Empty);
      stmt := new statement(WHILE_STMT);
      stmt.all.while_expr := expr;
      stmt.all.while_body := bk;
      return stmt;
   end make;

   ----------
   -- make --
   ----------

   function make (lvalue: in id; expr: in not null arithmetic_expression_access) return statement_access is
   stmt : statement_access;
   begin
      Assert(is_valid_id(get_lexeme(lvalue)));
      stmt := new statement(ASSN_STMT);
      stmt.all.var := lvalue;
      stmt.all.r_value := expr;
      return stmt;
   end make;

end statements;
