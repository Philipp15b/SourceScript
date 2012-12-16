describe "functions", ->
  it "should be inlined", ->
  	expectCompile """
      function testfunc() {
        command
      }
	  testfunc()
	  """,
	  """
	  command;
    """

  it "should be translated to aliases when using plus prefix", ->
    expectCompile """
      function +DoSomething() {
        cmd1
      }

      function -DoSomething() {
         cmd2
      }

      +DoSomething()
      """,
      """
      alias "+DoSomething" "cmd1; ";
      alias "-DoSomething" "cmd2; ";
      +DoSomething;
      """
