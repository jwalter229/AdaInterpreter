pragma Ada_2012;
with Ada.Characters.Conversions; use Ada.Characters.Conversions;
with Ada.Characters.Handling; use Ada.Characters.Handling;

with tokens; use tokens;

package body ids is

   ----------
   -- make --
   ----------

   function make (s: in string) return id is
      idd : id;
   begin
      if not Is_letter(s(1)) then
         raise invalid_identifier with s & " <-- character is not a valid identifier";
      end if;
      idd.l := tokens.make(s);
      return idd;
   end make;

   ----------------
   -- get_lexeme --
   ----------------

   function get_lexeme (this: in id) return lexeme is
   begin
      return this.l;
   end get_lexeme;

end ids;
