{BufferedProcess} = require "atom"

module.exports =
  exec         : (file, callback)->
    response = ""
    new BufferedProcess
      command : atom.config.get "hashrocket.phpExecutablePath"
      args    : [file]
      stdout  : (data)-> response += data.toString()
      exit    : -> callback response

  printer      : "?><$1><?php var_dump($2); ?></$1><?php"
  prefix       : "//=>"
  matcher      : /(\/\/=>)(.+)/gi
  comment      : "//"
