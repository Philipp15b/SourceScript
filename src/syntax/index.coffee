{readFileSync, writeFileSync} = require 'fs'
{dirname} = require 'path'
mkdirSync = require('mkdirp').sync
PEG = require 'pegjs'

repeat = (str, num) ->
  Array(num).join str

removeDuplicateWhitespace = (text) ->
  text.replace /[\t\v\f \u00A0\uFEFF]{2,}/, ""

ensureNewlineAtEnd = (text) ->
  if text.charAt(text.length - 1) != '\n'
    text += '\n'
  text

# Builds the parser from the grammar file
buildParser = () ->
  grammar = readFileSync("#{__dirname}/grammar.pegjs").toString()
  parser = PEG.buildParser grammar,
    trackLineAndColumn: on

  mkdirSync dirname "#{__dirname}/grammar-parser.js"
  writeFileSync "#{__dirname}/grammar-parser.js", "module.exports = #{parser.toSource()}"

parse = (contents) ->
  parser = require './grammar-parser.js'
  parser.parse removeDuplicateWhitespace ensureNewlineAtEnd contents

module.exports =
  buildParser: buildParser
  parse: parse
