{CompositeDisposable} = require 'atom'

module.exports = CheckInProcess =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'check-in-process:show-crs': => @createCodeReviewListView().showCodeReviewList()

  deactivate: ->
    @subscriptions.dispose()
    if @codeReviewListView?
      @codeReviewListView.destroy()
      @codeReviewListView = null

  createCodeReviewListView: ->
    unless @codeReviewListView?
      CodeReviewListView = require './code-review-list-view.coffee'
      @codeReviewListView = new CodeReviewListView()
    @codeReviewListView
