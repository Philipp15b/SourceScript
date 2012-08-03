{exec} = require 'child_process'
{readFileSync, existsSync, writeFileSync, unlinkSync} = require 'fs'
{mkdirSyncRecursive, rmdirSyncRecursive} = require 'wrench'

task 'clean', 'clean up the build path', ->
  parser = "#{__dirname}/src/syntax/grammar-parser.js"
  unlinkSync parser if existsSync parser
  rmdirSyncRecursive dir for dir in ['lib', 'bin'] when existsSync dir

task 'build', 'build SourceScript from source', ->
  mkdirSyncRecursive 'lib/syntax/'
  writeFileSync 'lib/syntax/grammar.pegjs', readFileSync('src/syntax/grammar.pegjs').toString()
  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    invoke 'build:parser'

task 'build:parser', 'rebuild the peg.js parser', ->
  syntax = require './lib/syntax'
  syntax.buildParser()
