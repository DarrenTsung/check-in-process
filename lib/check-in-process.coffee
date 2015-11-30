CheckInProcessView = require './check-in-process-view'
{CompositeDisposable} = require 'atom'

module.exports = CheckInProcess =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'check-in-process:show-crs': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    console.log 'CheckInProcess was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
