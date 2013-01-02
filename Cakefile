{exec} = require 'child_process'
{readFileSync, readdirSync, existsSync, renameSync, writeFileSync, unlinkSync} = require 'fs'
path = require 'path'
wrench = require 'wrench'
mkdirSync = require('mkdirp').sync
walkdir = require 'walkdir'
PEG = require 'pegjs'
UglifyJS = require 'uglify-js'
Mocha = require 'mocha'


task 'clean', 'clean up the build path', ->
  unlinkSync file for file in ['browser.js', 'browser.min.js'] when existsSync file
  wrench.rmdirSyncRecursive dir for dir in ['lib', 'bin'] when existsSync dir

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

task "test", "run tests", ->
  mocha = new Mocha
    reporter: 'spec'
  walkdir.sync('./test/').filter( (file) ->
    return file.substr(-7) is '.coffee' and file.indexOf('test-helper') is -1
  ).forEach (file) ->
    mocha.addFile file
  require './test/test-helper.coffee' # this pollutes the globals
  mocha.run()

# -----------------
# BROWSERIFY
# -----------------

task 'browserify', 'build for browserify', ->
  browserify = require 'browserify'
  {bundle} = browserify './lib/browserify.js'
  writeFileSync 'browser.js', bundle()

  invoke 'browserify:minify'

task 'browserify:minify', 'minify the browserified file', ->
  result = UglifyJS.minify './browser.js'
  writeFileSync './browser.min.js', result.code
