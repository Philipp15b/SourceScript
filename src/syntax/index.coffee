repeat = (str, num) ->
  Array(num).join str

removeDuplicateWhitespace = (text) ->
  text.replace /[\t\v\f \u00A0\uFEFF]{2,}/, ""

ensureNewlineAtEnd = (text) ->
  if text.charAt(text.length - 1) != '\n'
    text += '\n'
  text

module.exports.parse = (contents) ->
  parser = require './grammar-parser.js'
  parser.parse removeDuplicateWhitespace ensureNewlineAtEnd contents
