strings = require 'underscore.string'
SourceScript = require '../'

global.expectCompile = (source, expected) ->
  try
    compiled = SourceScript.compile 'test.ss': source
  catch e
    throw new Error "Compilation errror: #{e.message}"
  output = compiled['test.ss'].trim '\n '
  if output isnt expected
    throw new Error "Compiled source code does not match expectation! Expected:
    #{expected}

    Compiled:
    #{output}"
