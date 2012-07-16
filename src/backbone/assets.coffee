###
# Collection for AssetTypes
###
class AssetTypeCollection extends Backbone.Collection
  url: -> "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/asset_type"
  parse: (response) ->
    response.object_list

###
# Model for Assets
###
class AssetModel extends Backbone.Model
  urlRoot: -> "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/asset"
  collections: {}
  defaults:
    title: ''
    description: ''

  initialize: (options) ->
    super()
    ''

  clear: ->
    @destroy()
    @view.remove()

  parse: (response) ->
    # Asset payload also contains lists that are other collection types
    collections =
      comments: Crp.CommentCollection
      task_deadlines: Crp.TaskDeadlineCollection
      followers: Crp.FollowerCollection
      activities: Crp.ActivityCollection
      attachments: Crp.AttachmentCollection

    for key, collection of collections
      if response[key]?
        @collections[key] = new collection response[key], parent: response.id
        delete response[key]
    response

###
# Collection for Assets
###
class AssetCollection extends Backbone.Collection
  model: AssetModel
  # API URL
  url: -> "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/asset"
  # Since our API doesn't just return a collection of models, tell the
  # collection how to parse the API response.
  parse: (response) ->
    response.object_list

###
# View for a single Asset
###
class AssetView extends Crp.View
  template: 'asset-view-tmpl'
  className: 'asset-view'
  events:
    'click .follow': 'follow'
    'click .add-follower': 'addFollower'
    'click .add-comment': 'comment'

  inline:
    'h2':
      inputType: 'input'
      attribute: 'title'
    '.asset-description':
      inputType: 'textarea'
      attribute: 'description'

  childViews:
    'comments .comment-feed': 'CommentListView'
    'task_deadlines .task-feed': 'TaskListView'
    'followers .follower-feed': 'FollowerListView'
    'activities .activity-feed': 'ActivityListView'
    'attachments .attachment-feed': 'AttachmentView'

  initialize: (options) ->
    _.bindAll @, 'follow'
    # shortcuts
    @followers = @model.collections.followers
    @comments = @model.collections.comments
    @userac = new Crp.UserAutocompleteView()
    @

  ###
  # Handler for when 'Add Follower' button is clicked.
  # Creates a new model and adds it to the collection.
  #
  # TODO: implement this so users can search via name (and not id obv), w/
  # autocomplete
  ###
  addFollower: (e) ->
    user = @userac.getModel()
    @followers.create {userprofile_id: user.get 'id'}, {wait: true}
    @

  ###
  # Handler for when a user presses the 'Follow' button on an Asset
  #
  # Toggles following state.
  ###
  follow: (e) ->
    me = @me.get 'id'
    following = @followers.get me
    if following?
      following.destroy()
    else
      @followers.create userprofile_id: me
    @$('.follow').button('toggle')
    @

  ###
  # Posts a comment for a piece of asset
  ###
  comment: (e) ->
    comment_body = @$('.comment-input').val()
    @comments.create body: comment_body, {wait: true}
    @


  ###
  # Render the Asset Details
  ###
  render: (e) ->
    super
    # ugh don't know a good way to do this
    @$('.add-follower-input').empty().append(@userac.render().$el)
    @


###
View for an Asset row within the table view of Assets
###
class AssetRowView extends Crp.View
  editableField: '.title'
  template: 'asset-row-tmpl'
  tagName: 'tr'

  initialize: (options) ->
    @model.on 'change', @render, @
    @model.on 'destroy', @clear, @
    @

  clear: (e) ->
    @remove()

  render: (e) ->
    assetType = @getFrom @assetTypes, @model.get('asset_type_id'), 'current_version'
    data =
      assetTypeTitle: assetType.title
      duedate: @model.humanize 'next_task_due'
      url: @model.url().replace(Focus.Constants.API_URL, '')
    super e, data

# View that handles the table view of Assets
class AssetListView extends Crp.ListView
  view: AssetRowView
  initialize: (options) ->
    _.bindAll @, 'newRow', 'deleteRow'
    @pubsub.on 'input.enterPress', @newRow
    @pubsub.on 'input.deleteRow', @deleteRow
    @

  # enter pressed, make a new row
  newRow: (e) ->
    model = new AssetModel()
    @collection.add model, silent: true
    view = new @view
      model: model
      pubsub: @pubsub

    e.parent.$el.after view.render().el
    view.edit()
    @

  # delete pressed and input box is empty, delete row
  deleteRow: (e) ->
    e.parent.model.destroy()
    @

###
# View for Create Asset form
###
class AssetFormView extends Crp.ModalView
  modal: '#create-asset-modal'

  events:
    'submit': 'submit'

  initialize: (options) ->
    _.bindAll @, 'render'
    @pubsub.on 'asset.create', @render

  submit: (e) ->
    $form = $(e.currentTarget)
    console.log 'form', $form.formParams()
    new_asset = new AssetModel $form.formParams()
    console.log new_asset, new_asset.isNew()
    new_asset.save()
    false

window.namespace 'Crp', (exports) ->
  exports.AssetTypeCollection = AssetTypeCollection
  exports.AssetModel = AssetModel
  exports.AssetCollection = AssetCollection
  exports.AssetView = AssetView
  exports.AssetRowView = AssetRowView
  exports.AssetListView = AssetListView
  exports.AssetFormView = AssetFormView
