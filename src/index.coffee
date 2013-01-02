syntax = require './syntax'
semantics = require './semantics'
{GlobalScope} = require './semantics/scope'
plugins = require './plugins'
compiler = require './compiler'

module.exports.parse = syntax.parse

module.exports.compile = (files, options = {}) ->
  options.scope ?= new GlobalScope
  options.plugins ?= {}

  parsed = {}
  for name, content of files
    try
      parsed[name] = syntax.parse content
    catch e
      e.file = name
      throw e

  result = {}
  for name, ast of parsed
    try
      semantics ast, parsed, options.scope
      plugins ast, options.plugins
      result[name] = compiler ast
    catch e
      e.file = name
      throw e

  result
