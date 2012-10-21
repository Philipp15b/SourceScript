{exec} = require 'child_process'
{readFileSync, existsSync, writeFileSync, unlinkSync} = require 'fs'
{rmdirSyncRecursive} = require 'wrench'
mkdirSync = require('mkdirp').sync
PEG = require 'pegjs'
uglify = require 'uglify-js'


task 'clean', 'clean up the build path', ->
  unlinkSync file for file in ['browser.js', 'browser.min.js'] when existsSync file
  rmdirSyncRecursive dir for dir in ['lib', 'bin'] when existsSync dir

task 'build', 'build SourceScript from source', ->
  invoke 'clean'

  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    invoke 'build:parser'

task 'build:parser', 'build the peg.js parser', ->
  grammar = readFileSync('src/syntax/grammar.pegjs').toString()
  parser = PEG.buildParser grammar,
    trackLineAndColumn: on

  mkdirSync "./lib/syntax/" unless existsSync './lib/syntax'
  writeFileSync "./lib/syntax/grammar-parser.js", "module.exports = #{parser.toSource()}"

# -----------------
# BROWSERIFY
# -----------------

task 'browserify', 'build for browserify', ->
  browserify = require 'browserify'
  {bundle} = browserify './lib/browserify.js'
  writeFileSync 'browser.js', bundle()

  invoke 'browserify:minify'

task 'browserify:minify', 'minify the browserified file', ->
  original = readFileSync('./browser.js').toString()
  ast = uglify.parser.parse original
  ast =  uglify.uglify.ast_mangle ast
  ast = uglify.uglify.ast_squeeze ast
  code = uglify.uglify.gen_code ast
  writeFileSync './browser.min.js', code
