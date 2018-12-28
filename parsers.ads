with lexical_analyzers; use lexical_analyzers;
with programs; use programs;

package parsers is

   type parser is private;
   
   function make (file_name: in string) return parser;
   
   procedure parse (this: in out parser; prog: out program);
   
   parse_exception: exception;
   
private
   type parser is record
      lex: lexical_analyzer;
   end record;
   
end parsers;
