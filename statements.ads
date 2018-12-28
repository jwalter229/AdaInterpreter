with ids; use ids;
with arithmetic_expressions; use arithmetic_expressions;
with boolean_expressions; use boolean_expressions;
with iters; use iters;
private with Ada.Containers.Doubly_Linked_Lists;

package statements is
   
   type stmt_type is (ASSN_STMT, IF_STMT, FOR_STMT, WHILE_STMT, PRINT_STMT);

   type statement (s_type: stmt_type) is private;
   
   type statement_access is access all statement;
   
   procedure execute (this: in statement);
   
   type block is private;
   
   procedure add_statement (this: in out block; stmt: in not null statement_access);
   
   procedure execute (this: in block);
   
   function make (expr: in not null arithmetic_expression_access) return statement_access;
   
   function make (loop_var: in id; loop_control: in iter; bk: in block) return statement_access;
   
   function make (expr: in boolean_expression; if_block, else_block: in block) return statement_access;
   
   function make (expr: in boolean_expression; bk: in block) return statement_access;
   
   function make (lvalue: in id; expr: in not null arithmetic_expression_access) return statement_access;
   
private
   type statement (s_type: stmt_type) is record
         case s_type is
            when ASSN_STMT =>
               var: id;
               r_value: arithmetic_expression_access := null;
            when IF_STMT =>
               if_expr: boolean_expression;
               if_block: block;
               else_block: block;
            when FOR_STMT =>
               loop_var: id;
               loop_control: iter;
               for_body: block;
            when WHILE_STMT =>
               while_expr: boolean_expression;
               while_body: block;
            when PRINT_STMT =>
               print_expr: arithmetic_expression_access := null;
         end case;
      end record;
                
      package statement_list is new Ada.Containers.Doubly_Linked_Lists(statement_access);
   
      type block is record
         stmts: statement_list.list;
      end record;

end statements;
