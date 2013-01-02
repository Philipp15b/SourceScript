SourceScript = require '../'

describe "plugins", ->
  it "should be called", ->
    out = SourceScript.compile {'test.ss': ":testcommand"},
      plugins:
        testcommand: (cmd) ->
          cmd.compilercommand = no
          cmd.name = "testreplacement"
          cmd

    if out["test.ss"].indexOf("testreplacement;") is -1
      throw new Error "Replacement was not inserted!"


  it "should be allowed to return code", ->
    out = SourceScript.compile {'test.ss': ":testcommand"},
      plugins:
        testcommand: (cmd) ->
          "testreplacement # This is awesome"

    if out["test.ss"].indexOf("testreplacement;") is -1
      throw new Error "Replacement was not inserted!"

  it "must exist", ->
    failure = yes
    try
      SourceScript.compile 'test.ss': ":testcommand"
    catch e
      failure = e.message.indexOf("Could not find compiler command") is -1
    if failure
      throw new Error "Error expected!"
