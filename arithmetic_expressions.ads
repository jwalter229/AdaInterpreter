with tokens; use tokens;
with ids; use ids;

package arithmetic_expressions is

   type expr_type is (ID_EXPR, LIT_INT_EXPR, BIN_EXPR);
   
   type arithmetic_expression (expr: expr_type) is private;
   
   type arithmetic_expression_access is access all arithmetic_expression;
   
   type arithmetic_operator is (ADD_OP, SUB_OP, MUL_OP, REV_DIV_OP, DIV_OP, MOD_OP, EXP_OP);
   
   function make (var: in id) return arithmetic_expression_access;
   
   function make (value: in integer) return arithmetic_expression_access;
   
   function make (op: in arithmetic_operator; first, second: in not null arithmetic_expression_access)
     return arithmetic_expression_access;

   function evaluate (this: in arithmetic_expression) return integer;
   
   function get_value (this: in arithmetic_expression) return integer with pre => this.expr = LIT_INT_EXPR;
   
private
   type arithmetic_expression (expr: expr_type) is record
      case expr is
         when ID_EXPR => 
            var: id;
         when LIT_INT_EXPR =>
            value: integer := 0;
         when BIN_EXPR =>
            op: arithmetic_operator := ADD_OP;
            first: arithmetic_expression_access := null;
            second: arithmetic_expression_access := null;
      end case;
   end record;
end arithmetic_expressions;
