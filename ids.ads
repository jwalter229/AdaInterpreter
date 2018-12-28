with tokens; use tokens;

package ids is

   type id is private;
   
   function make (s: in string) return id;
   
   function get_lexeme (this: in id) return lexeme;
   
private
   type id is record
      l: lexeme;
   end record;

end ids;
