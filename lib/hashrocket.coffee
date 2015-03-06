{GitRepository, CompositeDisposable, Disposable} = require 'atom'
{$, TextEditorView, View}                        = require 'atom-space-pen-views'
Brokers                                          = require './brokers'
fs                                               = require 'fs'
os                                               = require 'os'
path                                             = require 'path'
_                                                = require 'underscore-plus'

module.exports =
  config:
    watchDebouceRate:
      type: 'integer'
      description: 'This is the amount of delay in ms after input stops before the code will be run. (Min: 700)'
      default: 700
      minimum: 700
    nodeExecutablePath:
      type: 'string'
      description: 'Command is run in process.env. If you want to specify a specific executable do so here.'
      default: if os.platform() isnt 'win32' then '/usr/bin/env node' else 'node'
    rubyExecutablePath:
      type: 'string'
      description: 'Command is run in process.env. If you want to specify a specific executable do so here.'
      default: if os.platform() isnt 'win32' then '/usr/bin/env ruby' else 'ruby'
    phpExecutablePath:
      type: 'string'
      description: 'Command is run in process.env. If you want to specify a specific executable do so here.'
      default: if os.platform() isnt 'win32' then '/usr/bin/env php' else 'php'
    pythonExecutablePath:
      type: 'string'
      description: 'Command is run in process.env. If you want to specify a specific executable do so here.'
      default: if os.platform() isnt 'win32' then '/usr/bin/env python' else 'python'
    bashExecutablePath:
      type: 'string'
      description: 'Command is run in process.env. If you want to specify a specific executable do so here.'
      default: if os.platform() isnt 'win32' then '/usr/bin/env bash' else 'bash'

  editorSub  : null
  activeFile : null
  delay      : null
  activate: (state) ->
    atom.commands.add 'atom-text-editor', 'hashrocket:run', => @run()
    atom.commands.add 'atom-text-editor', "hashrocket:insert", => @insertHashrocket()
    atom.commands.add 'atom-text-editor', "hashrocket:watchToggle", => @watchToggle()
    atom.commands.add 'atom-text-editor', "hashrocket:insertRun", =>
      @insertHashrocket()
      @run()
    delay = atom.config.get 'hashrocket.watchDebouceRate'
    atom.config.onDidChange 'hashrocket.watchDebouceRate', (values) =>
      @delay = values.newValue

  makeBroker: (args...)->
    {scope}         = @getEditor()
    broker          = Brokers.clients[scope]
    {exec, printer} = broker

    execute : exec
    printer : printer.replace /\$(\d+)/gi, (m)-> args[m[1]-1]

  setCode: (data)->
    {editor} = @getEditor()

    cursor   = editor.getCursorBufferPosition()

    editor.setText data
    editor.setCursorBufferPosition cursor

  generateToken: ->
    token = Math.random().toString(36)[2..].toUpperCase()

    "ATOM-HR-#{token}"

  getEditor: ->
    # workspace = atom.workspace
    editor    = atom.workspace.getActiveTextEditor()
    grammar   = editor.getGrammar()

    editor : editor
    scope  : grammar.scopeName
    name   : grammar.name
    code   : editor.getText()

  insertHashrocket: ->
    {editor, scope} = @getEditor()
    {prefix}        = Brokers.clients[scope]
    word            = editor.getWordUnderCursor() or ""

    editor.insertNewlineBelow()
    editor.insertText "#{prefix} #{word}"

  watchToggle: ->
    {editor}    = @getEditor()
    activePanel = null
    handleEvent = _.debounce (=> @run()), @delay
    if @watching
      @watching  = no
      # editor.emit "watch:stop"
      alert "Hashrocket stopped watching changes of #{@activeFile}"
      @editorSub?.dispose()
      @editorSub = null
    else
      @editorSub = new CompositeDisposable
      @watching = yes
      @run()

      item = atom.workspace.getActivePaneItem()
      @activeFile = item.buffer.file.path.split(/[\\]+/).pop()
      alert "Hashrocket is watching changes of #{@activeFile}"
      activePanel = atom.views.getView item
      activePanel.addEventListener('keydown', handleEvent)

      @editorSub.add new Disposable =>
        activePanel?.removeEventListener('keydown', handleEvent)

  run: ->
    fileToken = @generateToken()

    {code, scope, name} = @getEditor()

    broker = Brokers.clients[scope]

    unless broker
      alert "#{name} broker doesn't exist for Hashrocket."
      return

    {matcher, exec, comment} = broker
    tokens     = []

    # Clean all results
    code = code.replace ///#{comment}(.*)\sresult.*///gi, "#{comment}$1"

    tokenizedCode = code.replace matcher, (all, prompt, data)=>
      data = data.trim()
      token = @generateToken()
      {printer} = @makeBroker token, data

      tokens.push {token, data, printer}
      printer

    tokenFile = path.join os.tmpdir(), "#{fileToken}.#{scope}"
    fs.writeFileSync tokenFile, tokenizedCode

    exec tokenFile, (data)=>
      fs.unlink tokenFile
      fs.unlink tokenFile + ".js" if scope is "source.coffee"
      html = $ "<div>#{data}</div>"
      for token, index in tokens
        tokenInOut = html.find(token.token).last()
        tokens[index].output = if tokenInOut.length > 0 then tokenInOut.text().trim() else "unreachable"

      index = 0
      replacedCode = code.replace matcher, (all, prompt, data)=>

        {output} = tokens[index]

        # figure out somehow. CDATA may be useful.
        output = output
          .replace /\n/g, ' ' # single line outputs.
          .replace /&gt/g, '>'
          .replace /&lt/g, '<'

        replaced = "#{all} result #{output}"

        index++
        replaced

      @setCode replacedCode