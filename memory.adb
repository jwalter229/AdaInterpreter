pragma Ada_2012;

with Ada.Characters.Handling; use Ada.Characters.Handling;

package body memory is

   mem: array (0 .. 51) of integer := (others => 0);

   function get_index (l: in lexeme) return natural is
      ch: character := to_string (l)(1);
      index: natural;
   begin
      if not is_letter (ch) then
         raise invalid_identifier with ch & " is not a valid identifer";
      end if;
      if is_lower (ch) then
         index := character'pos(ch) - character'pos('a');
      else
         index := character'pos(ch) - character'pos('A') + 26;
      end if;
      return index;
   end get_index;

   -----------
   -- store --
   -----------

   procedure store (l: in lexeme; value: integer) is
   begin
      mem(get_index(l)) := value;
   end store;

   -----------
   -- fetch --
   -----------

   function fetch (l: in lexeme) return integer is
   begin
      return mem(get_index(l));
   end fetch;

end memory;
