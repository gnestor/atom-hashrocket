{BufferedProcess} = require "atom"

module.exports =
  exec         : (file, callback)->
    response = ""
    new BufferedProcess
      command : atom.config.get "hashrocket.bashExecutablePath"
      args    : [file]
      stdout  : (data)-> response += data.toString()
      exit    : -> callback response

  printer      : "echo \"<$1>`echo $2`</$1>\""
  prefix       : "#=>"
  matcher      : /(#=>)(.+)/gi
  comment      : "#"
