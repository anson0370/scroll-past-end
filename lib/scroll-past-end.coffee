module.exports =
  activate: ->
    {EditorView} = require "atom"
    EditorView.prototype.updateLayerDimensions = ->
      return unless atom.workspaceView.getActiveView() instanceof EditorView

      height = @lineHeight * @editor.getScreenLineCount()
      # patch code start
      if @closest(".pane").length > 0
        height = height + @height() - @lineHeight
      # patch code end
      if @layerHeight != height
        @layerHeight = height
        @underlayer.height(@layerHeight)
        @renderedLines.height(@layerHeight)
        @overlayer.height(@layerHeight)
        @verticalScrollbarContent.height(@layerHeight)
        if @scrollBottom() > height
          @scrollBottom(height)
      minWidth = Math.max(@charWidth * @editor.getMaxScreenLineLength() + 20, @scrollView.width())
      if @layerMinWidth != minWidth
        @renderedLines.css('min-width', minWidth)
        @underlayer.css('min-width', minWidth)
        @overlayer.css('min-width', minWidth)
        @layerMinWidth = minWidth
        @trigger('editor:min-width-changed')
