describe "functions", ->
  it "should be inlined", ->
  	expectCompile """
      function testfunc() {
        command
      }
	  testfunc()
	  """,
	  """
	  command
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
      alias +func_DoSomething cmd1
      alias -func_DoSomething cmd2
      +func_DoSomething
      """

  it "should be moved into auxiliary aliases out of binds", ->
    expectCompile """
    function +Hello() {
      echo "hello plus"
      echo "hello plus"
    }
    function -Hello() {
      echo "hello minus"
      echo "hello minus"
    }
    bind "p" {
      +Hello()
    }
    """,
    """
    alias +func_Hello "echo "hello plus"; echo "hello plus""
    alias -func_Hello "echo "hello minus"; echo "hello minus""
    alias +_bind_0 +func_Hello
    bind p +_bind_0
    """
