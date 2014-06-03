module.exports =
  configDefaults:
    retainHalfScreen: false

  activate: ->
    # patch for react editor
    DisplayBuffer = require "src/display-buffer"
    DisplayBuffer::getScrollHeight = ->
      if not @getLineHeightInPixels() > 0
        throw new Error("You must assign lineHeight before calling ::getScrollHeight()")
      # patch code start
      height = @getLineCount() * @getLineHeightInPixels()
      if atom.config.get("scroll-past-end").retainHalfScreen
        height = height + @getHeight() / 2
      else
        height = height + @getHeight() - (@getLineHeightInPixels() * 3)
      # patch code end
      height

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
