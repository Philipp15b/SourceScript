Compiler = require './compiler'
Simplifier = require './simplifier'

module.exports = (file, otherFiles = {}) ->
  simplifier = new Simplifier file, otherFiles
  compiler = new Compiler no # debug isnt really helpful yet
  compiler.visit simplifier.transform file.ast
  compiler.compiled
