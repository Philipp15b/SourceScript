describe "blocks", ->
  it "should be inlined", ->
    expectCompile """
      alias "combo" {
        command1
        command2
      }
      """,
      """
      alias "combo" "command1; command2; ";
      """
