{BufferedProcess} = require "atom"
coffee            = require "coffee-script"
fs                = require "fs"

module.exports =
  exec         : (file, callback)->
    # convert to js and run
    try
      js       = coffee.compile fs.readFileSync(file).toString()
      jsFile   = "#{file}.js"
      fs.writeFileSync jsFile, js
      response = ""
      new BufferedProcess
        command : atom.config.get "hashrocket.nodeExecutablePath"
        args    : [jsFile]
        stdout  : (data)-> response += data.toString()
        exit    : -> callback response

  printer      : "console.log \"<$1>\#{$2}</$1>\""
  prefix       : "#=>"
  matcher      : /(#=>)(.+)/gi
  comment      : "#"
