{readFileSync, writeFileSync} = require 'fs'
SourceScript = require '../src/'
util = require 'util'

SourceScript.buildParser()

code = readFileSync("#{__dirname}/simple.ss").toString()
console.log code, '\n'

try
  ast = SourceScript.addSemantics SourceScript.parse code
  console.log(util.inspect ast, false, null)
catch e
  console.log "Error compiling: #{e.message} on line #{e.line}, column #{e.column}"
  return
  

compiled = SourceScript.compile code, on
console.log '\n'
console.log compiled

writeFileSync 'compiled.cfg', compiled