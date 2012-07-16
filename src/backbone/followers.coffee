class FollowerModel extends Backbone.Model
  initialize: (attributes) ->
    if attributes.id?
      @set 'userprofile_id', attributes.id
  clear: ->
    @destroy()
    @view.remove()

class FollowerCollection extends Backbone.Collection
  model: FollowerModel
  keyName: 'followers'
  initialize: (data, options) ->
    super
    @parent = options.parent if options.parent?

  url: ->
    return "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/asset/#{ @parent }/followers"

class FollowerListView extends Crp.ListView
  addRow: (model) ->
    user_id = model.get 'userprofile_id'
    user = @users.get user_id

    if user?
      profile_image = user.profileImage()
      model.view = profile_image
      @$el.append(profile_image.$el)
    @

window.namespace 'Crp', (exports) ->
  exports.FollowerCollection = FollowerCollection
  exports.FollowerListView = FollowerListView
  exports.FollowerModel = FollowerModel
