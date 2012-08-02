util = require 'util'
{buildParser, parse} = require './syntax'
addSemantics = require './semantics'
compileAST = require './compiler'

compile = (code) ->
  compileAST addSemantics parse code

module.exports = 
  buildParser: buildParser
  parse: parse
  addSemantics: addSemantics
  compileAST: compileAST
  compile: compile
