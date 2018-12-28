with statements; use statements;
with ids; use ids;

package programs is

   type program is private;
   
   function make (func_name: in id; bk: in block) return program;
   
   procedure execute (this: in program);
   
private
   type program is record
      func_name: id;
      bk: block;
   end record;
   
end programs;
