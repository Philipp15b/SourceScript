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
      alias "+DoSomething" "cmd1";
      alias "-DoSomething" "cmd2";
      +DoSomething;
      """

  it "should be moved into auxiliary aliases out of binds", ->
    expectCompile """
    function +Hello() {
      echo "hello plus"
    }
    function -Hello() {
      echo "hello minus"
    }
    bind "p" {
      +Hello()
    }
    """,
    """
    alias "+_bind_0" "echo "hello plus"";
    alias "-_bind_0" "echo "hello minus"";
    bind "p" "+_bind_0";
    """
