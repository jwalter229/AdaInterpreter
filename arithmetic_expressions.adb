pragma Ada_2012;

with memory; use memory;

package body arithmetic_expressions is

   ----------
   -- make --
   ----------

   function make (var: in id) return arithmetic_expression_access is
      expr: arithmetic_expression_access;

   begin
      expr := new arithmetic_expression(ID_EXPR);
      expr.all.var := var;
      return expr;
   end make;

   ----------
   -- make --
   ----------

   function make (value: in integer) return arithmetic_expression_access is
      expr:  arithmetic_expression_access;
   begin
      expr := new arithmetic_expression (LIT_INT_EXPR);
      expr.all.value := value;
      return expr;
   end make;

   ----------
   -- make --
   ----------

   function make  (op: in arithmetic_operator;  first, second: in not null arithmetic_expression_access)
                   return arithmetic_expression_access is
      expr: arithmetic_expression_access;
   begin
      expr := new arithmetic_expression(BIN_EXPR);
      expr.op := op;
      expr.first := first;
      expr.second := second;
      return expr;
   end make;

   --------------
   -- evaluate --
   --------------

   function evaluate (this: in arithmetic_expression) return integer is
      result: integer;
   begin
      case this.expr is
         when ID_EXPR =>
            result := fetch (get_lexeme (this.var));
         when LIT_INT_EXPR =>
            result := this.value;
         when BIN_EXPR =>
            case this.op is
               when ADD_OP =>
                  result := evaluate (this.first.all) + evaluate (this.second.all);
               when SUB_OP =>
                  result := evaluate (this.first.all) - evaluate (this.second.all);
               when MUL_OP =>
                  result := evaluate (this.first.all) * evaluate (this.second.all);
               when DIV_OP =>
                  result := evaluate (this.first.all) / evaluate (this.second.all);
               when MOD_OP =>
                  result := evaluate (this.first.all) mod evaluate (this.second.all);
               when EXP_OP =>
                  result := evaluate (this.first.all) ** evaluate (this.second.all);
               when REV_DIV_OP =>
                  result := evaluate (this.second.all) / evaluate (this.first.all);
            end case;
      end case;
      return result;
   end evaluate;

   -----------------------------------------------------------------------------------------------------------------------

   function get_value (this: in arithmetic_expression) return integer is
   begin
      return this.value;
   end get_value;

end arithmetic_expressions;
