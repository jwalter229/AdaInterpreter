with arithmetic_expressions; use arithmetic_expressions;
with Ada.Finalization; use Ada.Finalization;

package iters is

   type iter is new Ada.Finalization.Controlled with private;
   
   function make (expr1, expr2: in not null arithmetic_expression_access) return iter;
   
   function get_start_expr (this: in iter) return arithmetic_expression_access;
   
   function get_end_expr (this: in iter) return arithmetic_expression_access;
   
   
private
   type iter is new Ada.Finalization.Controlled with record
      start_expr: arithmetic_expression_access := null;
      end_expr: arithmetic_expression_access := null;
   end record;

end iters;
