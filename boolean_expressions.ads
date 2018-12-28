with arithmetic_expressions; use arithmetic_expressions;

package boolean_expressions is

   type boolean_expression is private;

   type relational_operator is (EQ_OP, NE_OP, LT_OP, LE_OP, GT_OP, GE_OP);

   function make (op: in relational_operator; expr1, expr2: in not null arithmetic_expression_access)
                  return boolean_expression;

   function evaluate (this: in boolean_expression) return boolean;

private
   type boolean_expression is record
      op: relational_operator := EQ_OP;
      first: arithmetic_expression_access := null;
      second: arithmetic_expression_access := null;
   end record;

end boolean_expressions;
