private with Ada.Containers.Doubly_Linked_Lists;
with tokens; use tokens;

package lexical_analyzers is
   
   type lexical_analyzer is private;
   
   lexical_exception: exception;
   
   function make (file_name: in string) return lexical_analyzer;
   
   procedure get_next_token (this: in out lexical_analyzer; tok: out token)
     with pre => has_more_tokens (this);
   
   function get_lookahead_token (this: in lexical_analyzer) return token
     with pre => has_more_tokens(this);
   
   function has_more_tokens (this: in lexical_analyzer) return boolean;
   --new procedure--
   procedure print_lex(this : in lexical_analyzer);
   
private
   
   package token_lists is new Ada.Containers.Doubly_Linked_Lists(Element_Type => token);
   
   type lexical_analyzer is record
      token_list: token_lists.list;
   end record;
   
end lexical_analyzers;
