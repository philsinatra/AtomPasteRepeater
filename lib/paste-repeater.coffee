PasteRepeaterView = require './paste-repeater-view'
{CompositeDisposable} = require 'atom'

module.exports =
  activate: ->
    @view = new PasteRepeaterView()

  deactivate: ->
    @view?.destroy()
