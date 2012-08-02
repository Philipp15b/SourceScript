{
  var n = require('./nodes');
  var helpers = require('./grammar-helpers');
}

start
  = Program

Whitespace
  = " "  
_
  = Whitespace*

__
  = Whitespace+
  
Indent
  = "Indent" __
  
Outdent
  = "Outdent" __

Identifier "Identfier"
  = name:[a-zA-Z0-9]+
     { return name.join(""); }

EndOfLine
  = '\n'
  / "\r\n"
  / "\r"
  
BooleanLiteral
  = "true" { return true; }
  / "false" { return false; }

Program
  = program:(Statement StatementSeperator)*
    { return new n.Block(helpers.every(0, program)).p(line, column); }
    
StatementSeperator
  = (_ EndOfLine _)+
  / (_ ';' _)+
  
Block
  = _ "{" _ EndOfLine* _ program:Program _ "}"
     { return program; }

Statement
  = VariableAssignment
  / FunctionDeclaration
  / FunctionCall
  / IfStatement
  / Command
  / Comment

VariableAssignment
  = name:Identifier _ "=" _ expr:BooleanLiteral
    { return new n.VariableAssignment(name, expr).p(line, column); }

FunctionDeclaration
  = "function" __ name:Identifier _ "()" _ expr:Block
    { return new n.FunctionDeclaration(name, expr).p(line, column); }
  
FunctionCall
  = name:Identifier _ "()"
     { return new n.FunctionCall(name).p(line, column); }
  
IfStatement
  = "if" __ condition:Condition _ yes:Block _ "else" _ no:Block
     { return new n.IfStatement(condition, yes, no).p(line, column); }
  / "if" __ condition:Condition _ yes:Block
     { return new n.IfStatement(condition, yes).p(line, column); }
     
Condition
  = negated:'!'? _ condition:Identifier
     { return new n.Condition(condition, negated != "").p(line, column); }
  
Command
  = name:Identifier __ args:(CommandArgument _)*
     { return new n.Command(name, helpers.every(0, args)).p(line, column); }
  
CommandArgument
  = '"' content:(!'"' .)* '"' { return helpers.every(1, content).join(""); }
  
Comment
  = '#' content:(!EndOfLine .)* 
     { return new n.Comment(helpers.every(1, content).join("")); }
