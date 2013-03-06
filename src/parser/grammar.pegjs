{
  var n = require('../nodes'),
      helpers = require('./helpers'),
      EVERY = helpers.every;
}

start
  = Program

ws "Whitespace"
   = [\t\v\f \u00A0\uFEFF]

EndOfLine "End of Line"
  = '\n'
  / "\r\n"
  / "\r"

_
  = ws*

__
  = ws+

_EOL
  = (ws / EndOfLine)*

Identifier "Identfier"
  = name:([a-zA-Z0-9+-] / '_')+
     { return name.join(""); }

StringLiteral "String"
  = '"' content:(!'"' .)* '"'
     { return EVERY(1, content).join(""); }
  / content:(!(ws / '"' / EndOfLine / ';' / '{' / '#') .)+
     { return EVERY(1, content).join(""); }

StatementSeperators
  = ( _ (EndOfLine / ';') _ )+

Program
  = program:(Statement Comment? StatementSeperators)* StatementSeperators?
    { return new n.Block(helpers.filterProgram(program)).p(line, column); }

Block
  = "{" _EOL program:Program _EOL "}"
     { return program; }

Statement
  = Comment
  / Assignment
  / &"$" v:Variable { return v; }
  / IfStatement
  / Command

Comment "Comment"
  = ('#' / '//') content:(!EndOfLine .)*
     { return new n.Comment(EVERY(1, content).join("")); }

// ----------------------
// Commands
// ----------------------
Command "Command"
  = prefix:":"? name:Identifier args:(__ (CommandArgument _)*)?
     { return new n.Command(name, args === "" ? [] : EVERY(0, args[1]), prefix === ":").p(line, column); }

CommandArgument
  = Block
  / StringLiteral

// ----------------------
// Assignments
// ----------------------
Variable
  = prefix:"$"? name:Identifier
    { return new n.Variable(name, prefix === "$").p(line, column); }

Assignment "Assignment"
  = variable:Variable _ "=" _ value:Expression
    { return new n.Assignment(variable, value).p(line, column); }

Expression "Expression"
  = val:("true" / "false")
    {
      return new n.Block([
        new n.Command(val === "true" ? "TrueHook" : "FalseHook", [], false).p(line, column)
      ]).p(line, column);
    }
  / Block

// ----------------------
// Conditional Statements
// ----------------------
IfStatement "If Statement"
  = "if" __ prefix:'!'? condition:Variable _ yes:Block no:(_ "else" _ Block)?
     {
       no = no !== "" ? no[3] : new n.Block([]);
       if (prefix === '!') {
        var temp = yes;
        yes = no;
        no = temp;
       }
       return new n.IfStatement(condition, yes, no).p(line, column);
     }
