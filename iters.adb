pragma Ada_2012;
package body iters is

   ----------
   -- make --
   ----------

   function make (expr1, expr2: in not null arithmetic_expression_access) return iter is
      it : iter;
   begin
      it.start_expr := expr1;
      it.end_expr := expr2;
      return it;
   end make;

   --------------------
   -- get_start_expr --
   --------------------

   function get_start_expr (this: in iter) return arithmetic_expression_access is
   begin
      return this.start_expr;
   end get_start_expr;

   ------------------
   -- get_end_expr --
   ------------------

   function get_end_expr (this: in iter) return arithmetic_expression_access is
   begin
      return this.end_expr;
   end get_end_expr;

end iters;
