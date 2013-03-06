{expectCompile} = require './helpers'

describe "assignment", ->
  describe "global", ->
    it "should compile to an alias", ->
      expectCompile """
      test = {
        cmd arg1 arg2
      }
      """,
      """
      alias test "cmd arg1 arg2"
      """

  describe "local", ->
    it "should compile to an alias", ->
      expectCompile """
      $test = {
        cmd arg1 arg2
      }
      """,
      """
      alias var_test_0 "cmd arg1 arg2"
      """

  it "should be transformed into auxiliary aliases when nested", ->
      expectCompile """
      test = {
        test2 = {
          cmd2
          cmd3
        }
        test2
      }
      """,
      """
      alias _assign_0 "cmd2; cmd3"
      alias test "alias test2 _assign_0; test2"
      """

  it "should have a plus or minus prefix at the beginning", ->
    expectCompile """
    $+test1 = true
    $-test2 = false
    """, """
    alias +var_test1_0 TrueHook
    alias -var_test2_1 FalseHook
    """
