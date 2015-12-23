_ = require 'underscore-plus'
{$, TextEditorView, View} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'

module.exports =
  class PasteRepeaterView extends View
    previouslyFocusedElement: null
    mode: null

    @content: ->
      @div class: 'paste-repeater', =>
        @subview 'miniEditor', new TextEditorView(mini: true)
        @div class: 'error', outlet: 'error'
        @div class: 'message', outlet: 'message'

    initialize: ->
      @commandSubscription = atom.commands.add 'atom-workspace',
        'paste-repeater': => @attach()

      @miniEditor.on 'blur', => @close()
      atom.commands.add @element,
        'core:confirm': => @confirm()
        'core:cancel': => @close()

    destroy: ->
      @panel?.destroy()
      @commandSubscription.dispose()

    attach: ->
      @panel ?= atom.workspace.addModalPanel(item: this, visible: false)
      @previouslyFocusedElement = $(document.activeElement)
      @panel.show()
      @message.text('Enter number of pastes')
      @miniEditor.focus()

    setInputText: ->
      editor = @miniEditor.getModel()
      editor.setText('')

    close: ->
      return unless @panel.isVisible()
      @panel.hide()
      @setInputText()
      @previouslyFocusedElement?.focus()

    confirm: ->
      @pasteCount = @miniEditor.getText().trim()
      # Verify input is a number
      if isNaN(@pasteCount)
        @close()
        @setInputText()
        false

      @pasteCount = Math.round(@pasteCount)
      @close()
      # Round number to closest whole number
      if editor = atom.workspace.getActiveTextEditor()
        @repeatCounter = 0
        while @repeatCounter < @pasteCount
          clipboardText = atom.clipboard.read()
          editor.insertText(clipboardText)
          @repeatCounter++
        true
      @setInputText()
      true
