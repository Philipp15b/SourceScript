util = require 'util'
{buildParser, parse} = require './syntax'
analyzeSemantics = require './semantics'
compileAST = require './compiler'

# Make sure all the dependencies of a file exist
validateDependencies = (files, fileMetadata) ->
  for name, data of fileMetadata
    for dep in data.dependencies
      unless files[dep]?
        throw new Error "Could not find dependency '#{dep}', depended on by #{name}"

compile = (files) ->
  # Parsing
  parsedFiles = {}
  for name, content of files
    parsedFiles[name] = parse content

  # Semantics
  fileMetadata = {}
  for filename, ast of parsedFiles
    fileMetadata[filename] = analyzeSemantics ast
  
  validateDependencies files, fileMetadata

  # Compiling
  compiledFiles = {}
  for name, ast of parsedFiles
    compiledFiles[name] = compileAST ast, name, fileMetadata

  compiledFiles


module.exports =
  buildParser: buildParser
  parse: parse
  analyzeSemantics: analyzeSemantics
  compileAST: compileAST
  compile: compile
