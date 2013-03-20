assert = require 'assert'
{expectCompile} = require './helpers'
SourceScript = require '../'
{Command} = SourceScript.nodes

describe "compiler command", ->
  it "should be replaced", ->
    plugins =
      cc: (cmd) ->
        assert.strictEqual cmd.args[0], "str1", "wrong argument"
        new Command "replaced", ["arg1"], false

    expectCompile plugins: plugins, """
    :cc str1
    """, """
    replaced arg1
    """

  it "should fail with an exception if it does not exist", ->
    assert.throws ->
      expectCompile """
      :thisdoesnotexist
      """, ""
    , (err) -> err instanceof SourceScript.CompilerError and /Could not find/.test err.message

  describe "enum", ->
    it "should compile to aliases", ->
      expectCompile """
      :enum toggle_something {
        cmd1
      } {
        cmd2
      } {
        cmd3
      }
      """, """
      alias toggle_something toggle_something_0
      alias toggle_something_0 "cmd1; alias toggle_something toggle_something_1"
      alias toggle_something_1 "cmd2; alias toggle_something toggle_something_2"
      alias toggle_something_2 "cmd3; alias toggle_something toggle_something_0"
      """

  describe "bind", ->
    it "should compile to aliases", ->
      expectCompile """
      :bind mouse1 {
        cmd1
        cmd2
      } {
        cmd3
        cmd4
      }
      """, """
      alias +_bind_1 "cmd1; cmd2"
      alias -_bind_1 "cmd3; cmd4"
      bind mouse1 +_bind_1
      """
