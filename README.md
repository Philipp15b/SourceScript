# SourceScript 2

SourceScript is a small and simple programming language that
aims to simplifiy programming configurations for Valve's
games based on the Source Engine.

## Installing

Make sure to have Node.js installed.

    git clone https://github.com/Philipp15b/SourceScript.git
    cd SourceScript
    npm install -g

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
