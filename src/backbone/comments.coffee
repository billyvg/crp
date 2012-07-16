class CommentModel extends Backbone.Model
  initialize: (attributes) ->
    @

  clear: ->
    @destroy()
    @view.remove()

class CommentCollection extends Backbone.Collection
  model: CommentModel
  keyName: 'comments'
  initialize: (data, options) ->
    super
    @parent = options.parent if options.parent?

  url: ->
    return "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/asset/#{ @parent }/comments"

  parse: (response) ->
    response.object_list

class CommentView extends Crp.View
  className: 'comment-unit'
  template: 'comment-tmpl'

  render: (e) ->
    data = @model.toJSON()
    user = @users.get data.userprofile_id
    profileImage = user.profileImage()

    data.profile_image = profileImage.$el.html()
    data.author = user.toJSON()
    super e, data
    @

class CommentListView extends Crp.ListView
  view: CommentView


window.namespace 'Crp', (exports) ->
  exports.CommentCollection = CommentCollection
  exports.CommentView = CommentView
  exports.CommentListView = CommentListView
  exports.CommentModel = CommentModel
