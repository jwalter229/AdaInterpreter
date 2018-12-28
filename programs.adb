pragma Ada_2012;
with statements; use statements;

package body programs is

   ----------
   -- make --
   ----------

   function make (func_name: in id; bk: in block) return program is
      prog : program;
   begin
      prog.func_name := func_name;
      prog.bk := bk;
      return prog;
   end make;

   -------------
   -- execute --
   -------------

   procedure execute (this: in program) is
   begin
      execute(this.bk);
   end execute;

end programs;
