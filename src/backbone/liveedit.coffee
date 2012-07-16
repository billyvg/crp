###
# Backbone View that makes use of Bootstrap's Typeahead module.
#
# Pass this view a Backbone collection and tell it which attribute to use as
# the autocomplete's source.
#
# Example:
# followers = new AutocompleteInputView({
#   collection: users,
#   source: 'fullname',
#   options: options
# })
# followers.render.$el
###
class AutocompleteInputView extends Crp.View
  tagName: 'input'
  events:
    'change': 'autocompleteSelect'

  initialize: (options) ->
    @source = options.source if options?
    @options = _.extend {}, options
    @

  # Triggered when an item in the typeahead is selected
  autocompleteSelect: (e) ->
    @trigger 'autocomplete.enter', @

  # Retrieves the Backbone Model that matches this view's value
  # Will have problems if you have multiple Models with the same attribute that
  # you are using as the typeahead's source.
  getModel: () ->
    # value of the input field
    value = @$el.val()
    @collection.find (model) =>
      source = model.get @source
      source is value

  # Render the input and call Bootstrap's .typeahead() plugin
  render: ->
    options = _.extend @options, source: @collection.pluck @source
    @$el.typeahead options
    @

class UserAutocompleteView extends AutocompleteInputView
  initialize: (@options) ->
    super
    @collection = @users
    @source = 'fullname'
    @

class InlineInputView extends Crp.View
  tagName: 'input'

  events:
    'keydown': 'keypressed'
    'blur': 'doSave'

  initialize: (@options) ->
    $editable = options.parent
    value = $.trim($editable.text())

    @value = if options.value? then options.value else value
    @parent = options.parent if options.parent?
    @saveCallback = options.saveCallback if options.saveCallback?
    @

  keypressed: (e) ->
    # listen for "enter" keypress
    if e.which is 13 and not _.isEmpty $.trim(@$el.val())
      ''
      @doSave.apply @, arguments
    @

  doSave: (e) ->
    if not @saveCallback?
      throw 'Please define a "saveCallback."'
    @saveCallback @$el.val()

  render: ->
    if @tagName is 'input'
      @$el.attr
        type: 'text'
        value: @value
    else if @tagName is 'textarea'
      @$el.text @value

    # mimic the parent element's font properties and dimensions
    @$el.css
      width: @parent.width()
      height: @parent.height()
      font: @parent.css 'font'

    @parent.before(@$el).hide()
    @$el.focus()
    @

class InputView extends Crp.View
  tagName: 'input'

  events:
    'blur': 'blurred'
    'keydown': 'keypressed'

  initialize: (options) ->
    @value = options.value if options.value?
    @parent = options.parent if options.parent?
    @

  blurred: (e) ->
    @pubsub.trigger 'input.blur', @

    if _.isEmpty $.trim(@$el.val())
      @pubsub.trigger 'input.deleteRow', @
    @

  keypressed: (e) ->
    # listen for "enter" keypress
    if e.which is 13 and not _.isEmpty $.trim(@$el.val())
      @pubsub.trigger 'input.blur', @
      # figure out a good way to do this so that the proper parent
      # container receives this event and shows a new row
      @pubsub.trigger 'input.enterPress', @

    # listen for "backspace" keypress
    if e.which is 8 and _.isEmpty $.trim(@$el.val())
      @pubsub.trigger 'input.deleteRow', @
      e.preventDefault()
    @

  render: ->
    @$el.attr
      type: 'text'
      value: @value
    @$el.focus()
    @

class LiveEditView extends Crp.View
  constructor: (options) ->
    super

class ScratchpadView extends Crp.View
  editableField: '.sp-content'

  constructor: (options) ->
    super

    @view = options.view if options.view?
    @editing = false

    events =
      'click': 'rowClick'
    events['click ' + @editableField] = 'editableClick'
    @delegateEvents _.extend events, @events

    _.bindAll @, 'save', 'edit'
    @pubsub.on 'input.blur', @save

    @

  editableClick: (e) ->
    @pubsub.trigger 'list.editable.click', e, @model
    # edit title
    if not @editing and not $(e.target).hasClass('asset-title')
      @edit e

  rowClick: (e) ->
    @pubsub.trigger 'list.row.click', e, @model
    # edit title
    if not @editing and not $(e.target).hasClass('asset-title')
      @edit e

  edit: (e) ->
    console.log 'asset editing'
    $editable = @$el.find(@editableField)
    value = $.trim($editable.find('a').text())

    $input = new Crp.InputView
      value: value
      pubsub: @pubsub
      parent: @

    $editable.html($input.render().el)
    $input.$el.focus()
    @editing = true

  save: (e) ->
    # input box was blurred and/or entered pressed
    if @editing
      @model.set {
        name: $.trim(e.$el.val())
      },
        silent: true

      #@model.save()
      @render()
      @editing = false

      console.log 'saving input box'


window.namespace 'Crp', (exports) ->
  exports.InputView = InputView
  exports.InlineInputView = InlineInputView
  exports.ScratchpadView = ScratchpadView
  exports.LiveEditView = LiveEditView
  exports.UserAutocompleteView = UserAutocompleteView
