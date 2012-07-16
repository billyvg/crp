# Main Application view
class App extends Backbone.View
  events:
    'click': 'appClicked'
    "click a[href^='/']": 'linkClicked'

  initialize: (options) ->
    #@connectWebsocket()
    @pubsub = Crp.PubSub

    _.extend Crp.View.prototype,
      pubsub: @pubsub
      socket: @socket

    _.bindAll @, 'initializeBackbone', 'openWorkspace'
    @pubsub.on 'workspace.open', @openWorkspace

    @router = new top.Crp.Router
      pubsub: @pubsub

    Backbone.history.start
      pushState: true
      root: '/crp2/app/'

    _.extend Crp.View.prototype,
      router: @router

    @

  ###
  # Create all the different Collections/Views that we need
  ###
  initializeBackbone: ->
    # Collections that will be available to Crp.View
    @users = new Crp.UserCollection()
    @users.fetch
      success: (r) =>
        @me = @users.get Focus.Data.user_id
        _.extend Crp.View.prototype,
          me: @me

    @tasks = new Crp.TaskCollection()
    @tasks.fetch()

    @assetTypes = new Crp.AssetTypeCollection()
    @assetTypes.fetch()

    _.extend Crp.View.prototype,
      users: @users
      tasks: @tasks
      assetTypes: @assetTypes

    @assets = new Crp.AssetCollection()
    @assetview = new Crp.AssetListView
      collection: @assets
      el: '.asset-table tbody'
    @assets.fetch()

    @detail = new Crp.DetailModel()
    @detailview = new Crp.DetailView
      model: @detail
      el: '#details'

    @globalFeedItems = new Backbone.Collection()
    @globalFeed = new Crp.ActivityListView
      collection: @globalFeedItems
      el: '#global-activity'

    @assetForm = new Crp.AssetFormView()
    @

  ###
  # Connect o websocket
  ###
  connectWebsocket: ->
    if not window.io?
      # SocketIO not loaded, problems with node
    else
      socket = new Crp.Socket
        host: Crp.Data.nodehost
        port: Crp.Data.nodeport
      @socket = socket.socket

  appClicked: (e) ->
    @pubsub.trigger 'app.clicked', @

  # link in application was clicked, handle pushState
  linkClicked: (e) ->
    if not e.altKey and not e.ctrlKey and not e.metaKey and not e.shiftKey
      e.preventDefault()
      url = if @workspace? then "/workspace/#{ @workspace }/" else ''
      url += $(e.currentTarget).attr('href').replace(/^\//, '')
      Backbone.history.navigate url, trigger: true
    false

  ###
  # Workspace is set
  ###
  openWorkspace: (@workspace) ->
    _.extend Backbone.Model.prototype,
      workspace: workspace
    _.extend Backbone.Collection.prototype,
      workspace: workspace

    console.log workspace
    @initializeBackbone()

window.namespace 'Crp', (exports, top) ->
  exports.App = App

