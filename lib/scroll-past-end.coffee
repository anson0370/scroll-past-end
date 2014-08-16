module.exports =
  configDefaults:
    retainHalfScreen: false

  activate: ->
    # patch for react editor
    DisplayBuffer = require "src/display-buffer"
    DisplayBuffer::getScrollHeight = ->
      # patch code start
      lineHeight = if @getLineHeight then @getLineHeight() else @getLineHeightInPixels()
      return 0 unless lineHeight > 0
      scrollHeight = @getLineCount() * lineHeight
      if @height?
        if atom.config.get("scroll-past-end").retainHalfScreen
          scrollHeight = scrollHeight + @height / 2
        else
          scrollHeight = scrollHeight + @height - (lineHeight * 3)
      scrollHeight
      # patch code end

    # patch for classic editor
    EditorView = require "src/editor-view"
    EditorView::updateLayerDimensions = ->
      height = @lineHeight * @editor.getScreenLineCount()
      # patch code start
      if @closest(".pane").length > 0 && atom.workspaceView.getActiveView() instanceof EditorView
        if atom.config.get("scroll-past-end").retainHalfScreen
          height = height + @height() / 2
        else
          height = height + @height() - (@lineHeight * 3)
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
