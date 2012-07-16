class LoadingView  extends Crp.View
  template: 'loading-tmpl'
  initialize: (options) ->
    @parent = options.parent if options.parent?
    @

  render: ->
    # render loading overlay
    @$el.html(Focus.Template(@template)())
