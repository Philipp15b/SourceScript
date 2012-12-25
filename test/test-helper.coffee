strings = require 'underscore.string'
SourceScript = require '../'

global.expectCompile = (source, expected) ->
  compiled = SourceScript.compile 'test.ss': source
  output = compiled['test.ss'].trim '\n '
  if output isnt expected
    throw new Error "Compiled source code does not match expectation! Expected:
    #{expected}

    Compiled:
    #{output}"
