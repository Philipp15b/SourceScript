assert = require 'assert'
SourceScript = require '../'

# options parameter is optional
module.exports.expectCompile = (options, source, expected) ->
  unless expected?
    [source, expected] = [options, source]
    options = {}
  compiled = SourceScript.compile {'test.ss': source}, options
  output = compiled['test.ss'].trim '\n '
  assert.strictEqual output, expected, "expected compiled code to match expectation"
