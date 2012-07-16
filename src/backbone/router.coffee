class Router extends Backbone.Router
  initialize: (options) ->
    @pubsub = options.pubsub if options.pubsub?

  routes:
    '': 'workspaceIndex'
    'workspace/:id': 'home'
    'workspace/:id/asset/create': 'createAsset'
    'workspace/:id/asset/:id': 'viewAsset'
    'workspace/:id/asset/:id/full': 'viewAssetFull'
    '*path': 'defaultRoute'

  workspaceIndex: ->
    @pubsub.trigger 'workspace.list'
    console.log 'worksp'

  home: (workspace) ->
    @pubsub.trigger 'workspace.open', workspace
    @pubsub.trigger 'index.open'

  createAsset: (workspace) ->
    @pubsub.trigger 'workspace.open', workspace
    @pubsub.trigger 'asset.create'

  viewAsset: (workspace, asset) ->
    @pubsub.trigger 'workspace.open', workspace
    @pubsub.trigger 'detail.open',
      {type: 'asset', id: asset}
    console.log 'PushState: View Asset ', asset
    ''

  viewAssetFull: (workspace, asset) ->
    @pubsub.trigger 'workspace.open', workspace
    @pubsub.trigger 'detail.open.full',
      {type: 'asset', id: asset}
    console.log 'PushState: View Asset Full ', asset
    ''

  # default route
  defaultRoute: (path) ->
    console.log '*!! Undefined Route', path

window.namespace 'Crp', (exports) ->
  exports.Router = Router
