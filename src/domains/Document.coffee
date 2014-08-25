
Abstract = require('./Abstract')
Native   = require('../methods/Native')

class Document extends Abstract
  priority: Infinity

  Methods:     Native::mixin {},
               Abstract::Methods,
               require('../methods/Selectors'),
               require('../methods/Rules')

  Queries:     require('../modules/Queries')
  Positions:   require('../modules/Positions')

  helps: true

  constructor: () ->
    if document?
      @engine.queries   ||= new @Queries(@)
      @engine.positions ||= new @Positions(@)
      @engine.applier   ||= @engine.positions
      @engine.scope     ||= document
      @engine.all         = @engine.scope.getElementsByTagName('*')
      
      if @scope.nodeType == 9 && ['complete', 'interactive', 'loaded'].indexOf(@scope.readyState) == -1
        @scope.addEventListener 'DOMContentLoaded', @
      else if @running
        @compile()

      @scope.addEventListener 'scroll', @
      if window?
        window.addEventListener 'resize', @

    super
    
  events:
    resize: (e = '::window') ->
      id = e.target && @identity.provide(e.target) || e
      @solve id + ' resized', ->
        @intrinsic.verify(id, "width", undefined, false)
        @intrinsic.verify(id, "height", undefined, false)
      
    scroll: (e = '::window') ->
      id = e.target && @identity.provide(e.target) || e
      @solve id + ' scrolled', ->
        @intrinsic.verify(id, "scroll-top", undefined, false)
        @intrinsic.verify(id, "scroll-left", undefined, false)

    solve: ->
      # Unreference removed elements
      if @removed
        for id in @removed
          @identity.unset(id)
        @removed = undefined

    # Observe stylesheets in dom
    DOMContentLoaded: ->
      @scope.removeEventListener 'DOMContentLoaded', @
      @start()

    # Observe and parse stylesheets
    compile: ->
      @engine.solve 'Document', 'stylesheets', [
        ['eval',  ['$attribute', ['$tag', 'style'], '*=', 'type', 'text/gss']]
        ['load',  ['$attribute', ['$tag', 'link' ], '*=', 'type', 'text/gss']]
      ]

    destroy: ->
      @scope.removeEventListener 'DOMContentLoaded', @
      @scope.removeEventListener 'scroll', @
      window.removeEventListener 'resize', @
      @engine.events.destroy.apply(@, arguments)

  @condition: ->
    window?  
  url: null
module.exports = Document