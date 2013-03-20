{existsSync, writeFileSync} = require 'fs'

task 'clean', 'remove build files', ->
  {unlinkSync} = require 'fs'
  {rmdirSyncRecursive} = require 'wrench'

  unlinkSync file for file in ['browser.js', 'browser.min.js'] when existsSync file
  rmdirSyncRecursive dir for dir in ['lib', 'bin'] when existsSync dir

task 'build', 'clean, generate .js files and build the parser', ->
  {exec} = require 'child_process'

  invoke 'clean'

  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

    {existsSync, renameSync, mkdirSync} = require 'fs'
    mkdirSync './bin' unless existsSync './bin'
    renameSync './lib/command.js', "./bin/sourcescript.js"

    invoke 'build:parser'

task 'build:parser', 'build the peg.js parser', ->
  {readFileSync} = require 'fs'
  {buildParser} = require 'pegjs'
  mkdirSync = require('mkdirp').sync

  grammar = readFileSync('src/parser/grammar.pegjs').toString()
  parser = buildParser grammar,
    trackLineAndColumn: on

  mkdirSync "./lib/parser/" unless existsSync './lib/parser'
  writeFileSync "./lib/parser/grammar.js", "module.exports = #{parser.toSource()}"

task "test", "run tests", ->
  path = require 'path'
  Mocha = require 'mocha'
  {readdirSyncRecursive} = require 'wrench'

  mocha = new Mocha
    reporter: 'spec'
  test = path.join ".", "test"
  readdirSyncRecursive(test).filter( (file) ->
    path.extname(file) is '.coffee' and path.basename(file) isnt "helpers"
  ).forEach (file) ->
    mocha.addFile path.join test, file
  mocha.run()

task 'browserify', 'build with browserify', ->
  browserify = require 'browserify'
  UglifyJS = require 'uglify-js'

  b = browserify './lib/browserify.js'
  b.bundle (err, src) ->
    throw err if err
    writeFileSync 'browser.js', src

    minified = UglifyJS.minify src, fromString: yes
    writeFileSync './browser.min.js', minified.code
