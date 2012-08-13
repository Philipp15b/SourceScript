# SourceScript
SourceScript is a small and simple programming language that
aims to simplifiy programming configurations for Valve's
games based on the Source Engine.

It introduces boolean variables, conditional statements, enumerations
and some more readable syntax for commands.

## Syntax

SourceScript is fully backwards-compatible to the regular configuration files,
which means that you can just go ahead and copy your scripts to SourceScript
and enhance them with SourceScript-specific syntax.

### Extended Command Syntax

When defining aliases, you always write code as arguments which can be pretty messy.

SourceScript introduces a new syntax with braces that allows you to
write code like in every other language.

    alias "do" {
      +attack
      -attack
    }

As you can see, the code gets much more readable.

### Variables

With variables you can easily save yes/no states (called booleans).
`true` equals yes and `false` equals no.

Assigning a value to a variable just works like in any other programming language:

    isCompetitive = true

#### Variable scope

SourceScript is block-scoped. **TODO**

### Conditional Statements

To check for a variables value, use `if` statements:

    if isCompetitive {
      aimbotOff()
    } else {
      aimbotOn()
    }

This will check if isCompetitive is `true`. If yes, it will call the function
`aimbotOff` and if not, it will call `aimbotOn`.

#### Negations

To check for the inverted variable value, use an exclamation mark:

    if !isHungry {
      playMore()
    }

### Enumerations

Now this is a really handy feature of SourceScript. You can use enumerations to
scroll through a list of actions. Every time the enumeration is called,
The next block will be assigned to the name of the enumeration.

    enum nextweapon {
        {
           slot2
        },
        {
           slot3
        },
        {
           slot1
        }
    }

So when `nextweapon` is called, it will first execute the first command, `slot2`.
After that, it will assign the next command to `nextweapon` and so on.

Let's just see what that compiles to:
   
    alias nextweapon "nextweapon_0";
    alias nextweapon_0 "slot2; alias nextweapon "nextweapon_1"";
    alias nextweapon_1 "slot3; alias nextweapon "nextweapon_2"";
    alias nextweapon_2 "slot1; alias nextweapon "nextweapon_0"";

### Functions

SourceScript also introduces an easy syntax for functions.
They can be used to prevent code duplication.

    function do() {
       +attack
       -attack
    }
    
    alias "doit" {
      do();
    }

This will be compiled into:

    alias "doit" "+attack; -attack; "
  
As you can see, the function call will be replaced by the function code.
