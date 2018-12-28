with tokens; use tokens;

package memory is
   
   procedure store (l: in lexeme; value: integer) with pre => is_valid_id(l);
   
   function fetch (l: in lexeme) return integer with pre => is_valid_id(l);

end memory;
