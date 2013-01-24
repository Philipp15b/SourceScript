describe "assignments", ->
  it "should compile correctly with true", ->
    expectCompile 'test = true', 'alias var_0_test TrueHook'

  it "should compile correctly with false", ->
    expectCompile 'test = false', 'alias var_0_test FalseHook'

  it "should compile correctly when global", ->
    expectCompile '$test = false', 'alias var_test FalseHook'

describe "conditions", ->
  it "should compile correctly", ->
    expectCompile """
      test = true
      if test {
        this
      } else {
        that
      }
      """,
      """
      alias var_0_test TrueHook
      alias TrueHook this
      alias FalseHook that
      var_0_test
      """

  it "should compile correctly with negations", ->
     expectCompile """
      test = true
      if !test {
        this
      } else {
        that
      }
      """,
      """
      alias var_0_test TrueHook
      alias TrueHook that
      alias FalseHook this
      var_0_test
      """

  it "should compile correctly when nested", ->
    expectCompile """
      test = true
      test2 = true
      if test {
        if test2 {
          that1
          that2
        }
      }
      """,
      """
      alias var_0_test TrueHook
      alias var_1_test2 TrueHook
      alias _alias_2 "that1; that2"
      alias TrueHook "alias TrueHook _alias_2; alias FalseHook ""; var_1_test2"
      alias FalseHook ""
      var_0_test
      """
