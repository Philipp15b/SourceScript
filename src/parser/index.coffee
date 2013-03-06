parser = require './grammar.js'

module.exports = (code) ->
  code += '\n' if code.charAt(code.length - 1) isnt '\n'
  parser.parse code
