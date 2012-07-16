###
# Custom View that extends Backbone View
###
class Crp.View extends Backbone.View
  initStatus:
    childViews: false
    inline: false

  constructor: (options...) ->
    @pubsub = options.pubsub if options.pubsub?
    super
    _.bindAll @, 'render', 'showLoading', 'removeLoading',
      'bindInlineElements', 'createChildListViews'
    @

  # displays a loading 
  showLoading: (options) ->
    template = Focus.template('loading-tmpl')()
    @$('.loading').remove()
    @$el.prepend(template)
    @$('.loading').spin()

  # remove loading
  removeLoading: ->
    @$('.loading').remove()

  ###
  # Create childListViews for the different child collections the parent model
  # has.  Bind to the DOM.
  ###
  createChildListViews: ->
    feedFactory = (collection, options) =>
      $feed = @$(options.el)

      if Crp[options.viewName]?
        view = new Crp[options.viewName] collection: collection

        view.setElement $feed
        view.render()
      view

    for key, viewName of @childViews
      val = key.split ' '
      name = val[0]
      el = val[1]
      currentCollection = @model.collections[name]
      # check if keyName of collection is defined
      if currentCollection.keyName?
        view = "#{ currentCollection.keyName }View"
        @[view] = feedFactory currentCollection,
          viewName: viewName
          el: el
      else
        throw 'Please define "keyName" property for your Collection.'

    @initStatus.childViews = true
    @

  ###
  # Binds model attributes to html elements to be for inline editing
  ###
  bindInlineElements: ->
    if @inline?
      for selector, options of @inline
        do (selector, options) =>
          @$(selector).on 'click', (e) =>
            @editInline.call @, e, selector, options
    @initStatus.inline = true
    @

  editInline: (e, selector, options) ->
    $editable = $(e.target)

    # TODO: I don't think we need this inputview
    $input = new Crp.InlineInputView
      tagName: options.inputType
      parent: $editable
      saveCallback: (data) =>
        attr = {}
        attr[options.attribute] = data
        @saveInline.call @, attr

    $input.render()

  saveInline: (data) ->
    @model.set data, silent: true
    @model.save()
    @render()

  # Fetch an attribute from another collection
  # If key param is a string, then it will treat it as an attribute name and
  # fetch the foreign key from @model.
  getFrom: (foreign, key, attribute) ->
    id = if typeof key is 'string' then @model.get key else key
    model = foreign.get id
    return model.get attribute if model?
    null

  # default render method
  render: (e, data) ->
    model = _.extend @model.toJSON(), data
    @$el.html(Focus.template(@template)(model))
    @createChildListViews() if @childViews? and not e?
    @bindInlineElements() if @inline?
    @

class Crp.ListView extends Crp.View
  constructor: (options) ->
    super
    @view = options.view if options.view?

    @collection.on 'add', @addRow, @
    @collection.on 'remove', @removeRow, @
    @collection.on 'reset', @render, @
    @

  ###
  # Called when a model is added to the collection.
  # Renders a new row in the table view.
  ###
  addRow: (model) ->
    view = new @view
      model: model
    @$el.append(view.render().el)
    model.view = view
    @

  ###
  # Called when a model is removed from the collection.
  # Removes the item from the table view.
  ###
  removeRow: (model) ->
    model.clear()
    @

  # Clears the table view of Assets and re-renders it.
  render: ->
    @$el.html('')
    @collection.each (model) =>
      @addRow model
    @

###
# Base view for Modal Views
###
class Crp.ModalView extends Crp.View
  constructor: (options) ->
    super
    _.bindAll @, 'close'
    @pubsub.on 'index.open', @close
    @setElement @modal

  events:
    'hidden': 'hidden'

  # pushState URL to go to when modal is closed
  # TODO: navigating to root might not always be the case
  hidden: (e) ->
    #Backbone.history.navigate '/', trigger: true
    window.history.back()

  # close the modal window
  close: (e) ->
    @$el.modal 'hide'

  # display modal and navigate to app root when closed
  render: (e) ->
    @$el.modal
      backdrop: 'static',
      keyboard: true,
      show: true
