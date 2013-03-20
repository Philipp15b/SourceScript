assert = require 'assert'
{expectCompile} = require './helpers'
{CompilerError} = require '../'

describe 'conditionals', ->
  it "should compile to aliases", ->
    expectCompile """
    test = true
    if test {
      hello
      hello2
    } else {
      bye
      bye2
    }
    """, """
    alias test TrueHook
    alias TrueHook "hello; hello2"
    alias FalseHook "bye; bye2"
    test
    """

it "should fail when the variable is not defined", ->
  assert.throws ->
    expectCompile """
    if $test {
      something
    }
    """, ""
  , (err) -> err instanceof CompilerError and /Variable .* is not declared/.test err.message
