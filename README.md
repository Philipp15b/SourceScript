# SourceScript
SourceScript is a small and simple programming language that
aims to simplifiy programming configurations for Valve's
games based on the Source Engine.

It introduces boolean variables, conditional statements, enumerations, functions
and a more readable syntax for commands.

**See [the website](http://sourcescript.philworld.de/) for more information about the language and an interactive editor.**

## Building

Make sure to have Node.js installed.

    npm install -g coffee-script
    git clone https://github.com/Philipp15b/SourceScript.git
    cd SourceScript
    npm install
    cake build
    cake browserify

## API

To compile scripts via the API (a command-line interface not done yet), load SourceScript and call `compile`.

```coffee-script
SourceScript = require 'SourceScript'
files = 
  'some/folder/autoexec.ss': 'echo "hello world"'
try
   out = SourceScript.compile files
catch e
   console.log e
```

You can also create custom compiler commands (commands beginning with a `:`) through plugins.

```coffee-script
SourceScript = require 'SourceScript'
nodes = SourceScript.nodes

files = 
  'some/folder/autoexec.ss': 'echo "hello world"'
options = 
  plugins:
    'uselesscomment': (cmd) ->
       new nodes.Comment 'This comment is so useless'
try
   out = SourceScript.compile files, options
catch e
   console.log e
```

Now whenever you call `:uselesscomment` in your code, it will be replaced with a comment.