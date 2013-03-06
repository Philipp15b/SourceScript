path = require 'path'
fs = require 'fs'
parser = require 'nomnom'
wrench = require 'wrench'
SourceScript = require '../'

findSources = (base) ->
  return [] unless fs.existsSync base
  file = fs.statSync(base)
  if file.isFile() then [base]
  else if file.isDirectory()
    wrench.readdirSyncRecursive(base).filter( (name) ->
      path.extname(name) is ".ss"
    )
  else []

parser.script("sourcescript")
  .help("""
  - compile <file/directory>: Compile the given files
  - ast <file>: Print the Abstract Syntax Tree of the file
  """)
  .colors()

parser.command("compile")
  .help("Compile a .ss file into a .cfg file.")
  .option("files",
    position: 1
    default: "."
    help: ""
  )
  .option("output",
    abbr: "o"
    default: "."
    metavar: "DIR"
    help: "Write out all compiled files on the specified directory."
  )
  .callback (opts) ->
    names = findSources(opts.files)
    if names.length is 0
      console.error "Could not find any files!"
      return

    files = {}
    for name in names
      files[name] = fs.readFileSync name, 'utf8'

    out = SourceScript.compile files

    for name, contents of out
      name = name.replace(new RegExp(path.extname(name) + "$"), '.cfg') # change extension to .cfg
      fs.writeFileSync name, contents

parser.command("ast")
  .help("Show the AST of a file")
  .option("file",
    position: 1
    required: yes
  ).callback (opts) ->
    contents = fs.readFileSync opts.file, 'utf8'
    ast = SourceScript.parse contents
    console.log ast.toString()

parser.parse()
