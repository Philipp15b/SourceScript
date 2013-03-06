{expectCompile} = require './helpers'

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
