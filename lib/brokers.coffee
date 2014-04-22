module.exports =
  clients:
    "source.js"    : require "./brokers/js"
    "source.coffee": require "./brokers/coffee"
    "source.python": require "./brokers/python"
    "source.ruby"  : require "./brokers/ruby"
    "text.html.php": require "./brokers/php"
    "source.shell" : require "./brokers/bash"
