class DetailModel extends Backbone.Model
  initialize: (options) ->
    ''

class DetailView extends Crp.View
  events:
    'click .close': 'minimize'

  initialize: (options) ->
    @status = 'closed'
    _.bindAll @, 'render', 'open', 'expand', 'minimize'
    @pubsub.on 'detail.open', @open
    @pubsub.on 'detail.open.full', @expand
    @pubsub.on 'app.clicked', @minimize
    @model.on 'change:asset', @render
    @

  render: ->
    view = @model.get 'asset'
    @$el.find('.content').html(view.render().el)
    @pubsub.trigger 'detail.rendered', @
    @

  open: (options) ->
    @status = 'preview'
    @pubsub.trigger 'detail.load', @
    console.log 'Asset Title clicked (received in DetailView)', options
    #@model.set
      #asset: model
    @$el.css
      width: '300px'
      left: '713px'
      display: 'block'
    $('#main').css
      opacity: 1
      width: '700px'

  expand: (options) ->
    # only handle asset for now
    @status = 'expanded'
    console.log 'Expand Detail Window (in DV)', options
    model = new Crp.AssetModel id: options.id
    model.fetch
      success: () =>
        view = new Crp.AssetView model: model
        @model.set asset: view
        @removeLoading()

    @$el.css
      width: '1000px'
      left: '213px'
      display: 'block'
    $('#main').css
      opacity: '0.8'
      width: '1200px'
    @showLoading()

  minimize: (e) ->
    console.log 'Minimizing, status is', @status
    if @status is 'expanded'
      Backbone.history.navigate '/', trigger: true
      @$el.css
        width: 0
        left: '1012px'
        display: 'none'
      $('#main').css
        opacity: 1
        width: '1200px'
      @status = 'closed'

window.namespace 'Crp', (exports, top) ->
  exports.DetailModel = DetailModel
  exports.DetailView = DetailView
