path = require 'path'
{File} = require 'atom'
SelectListViewHelper = require './select-list-view-helper.coffee'

module.exports =
class CodeReviewListView extends SelectListViewHelper
  showCodeReviewList: ->
    @show()

    editor = atom.workspace.getActiveTextEditor()
    
    crPattern = ///
    CR                # the phrase 'CR'
    \s?               # 0 or 1 spaces
    \(                # '('
      ([^\)]+)        # capture everything inside the params
    \)                # ')'
    ///

    scanStartTime = (new Date).getTime()
    results = []
    atom.workspace.scan crPattern, (result) ->
      results.push(result)
    .then (res) =>
      scanElapsedTime = ((new Date).getTime() - scanStartTime) / 1000.0;
      # atom.notifications.addInfo("Scan elapsed time: " + scanElapsedTime, {dismissable: true})

      if results.length == 0
        @hide()
        return

      fileReadPromises = []
      matches = []
      for result in results
        fileAction = @findMatchesInFile(result.filePath, matches, crPattern)
        fileReadPromises.push(fileAction)

      Promise.all(fileReadPromises).then (res) =>
        @foundAllMatches(matches)

  findMatchesInFile: (currentFilePath, matches, matchPattern) ->
    file = new File(currentFilePath)

    file.read().then (fileText) ->
      lines = fileText.split("\n")

      rowIndex = 1
      for line in lines
        match = line.match(matchPattern)
        if match?
          matches.push({filePath: currentFilePath, rowIndex: rowIndex})
        rowIndex++

  foundAllMatches: (matches) ->
    viewObjects = []
    for match in matches 
      match.simpleText = path.basename(match.filePath) + ":" + match.rowIndex
      match.detailText = match.filePath
      viewObjects.push(match)

    @setItems(viewObjects)
    
  goToMatch: (indexMatch) ->
    @openPathToRow(indexMatch.filePath, indexMatch.rowIndex)

  openPathToRow: (filePath, rowIndex) ->
    if filePath
      atom.workspace.open(filePath).done => @moveToRowIndex(rowIndex)

  moveToRowIndex: (rowIndex) ->
    return unless rowIndex > 0

    if textEditor = atom.workspace.getActiveTextEditor()
      # buffer is zero indexed, but we display to user starting from 1
      # so subtract 1 when finding position
      position = new Point(rowIndex - 1)
      textEditor.scrollToBufferPosition(position, center: true)
      textEditor.setCursorBufferPosition(position)
      textEditor.moveToFirstCharacterOfLine()

  confirmed: (obj) ->
    super()
    @goToMatch(obj)
