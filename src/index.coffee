syntax = require './syntax'
semantics = require './semantics'
compiler = require './compiler'

# Parses and analyzes the given code.
#
# @param code The code
# @param variableIndex (optional) The variable index
#     to start counting the variables. This is important for
#     compiling multiple files, so that variables in different files
#     have different number prefixes, so that they do not collide.
# @return object
#     file: The file object describing the given piece of code.
#     variableIndex: The new variable index.
module.exports.parse = parse = (code, variableIndex = 0) ->
  file = {}

  # Parsing
  file.ast = syntax.parse code

  # Analyzing
  metadata = semantics file.ast, variableIndex
  file.functionDeclarations = metadata.functionDeclarations
  file.dependencies = metadata.dependencies
  
  {
    file: file
    variableIndex: metadata.variableIndex
  }

module.exports.compile = (files, libraryFiles = {}) ->
  variableIndex = 0
  # Parse libraries
  parsedLibraries = {}
  for name, content of libraryFiles
    parseResult = parse content, variableIndex
    parsedLibraries[name] = parseResult.file
    {variableIndex} = parseResult

  # Parse the actual files
  parsedFiles = {}
  for name, content of files
    parseResult = parse content, variableIndex
    parsedFiles[name] = parseResult.file
    {variableIndex} = parseResult
  
  # Merge all files to one big object that
  # is given to the compiler for information
  allFiles = parsedLibraries
  for name, file of parsedFiles
    allFiles[name] = file # Files from libraries will be
                        # overriden if they have the same name.

  # Now compile
  result = {}
  for name, file of parsedFiles
    result[name] = compiler file, allFiles

  result
