describe "enumerations", ->
  it "should compile correctly", ->
    expectCompile """
      enum next {
        {
          slot1
        },{
          slot2
        },{
          slot3
        }
      }
      """,
      """
      alias "next" "next_0";
      alias "next_0" "slot1; alias "next" "next_1"";
      alias "next_1" "slot2; alias "next" "next_2"";
      alias "next_2" "slot3; alias "next" "next_0"";
      """
