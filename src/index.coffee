syntax = require './syntax'
semantics = require './semantics'
{GlobalScope} = require './semantics/scope'
compiler = require './compiler'

module.exports.parse = syntax.parse

module.exports.compile = (files) ->
  parsed = {}
  for name, content of files
    try
      parsed[name] = syntax.parse content
    catch e
      e.file = name
      throw e

  globalScope = new GlobalScope
  result = {}
  for name, ast of parsed
    try
      semantics ast, parsed, globalScope
      result[name] = compiler ast
    catch e
      e.file = name
      throw e

  result
