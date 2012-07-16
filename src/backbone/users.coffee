class ProfileView extends Backbone.View
  template: 'profile-image-tmpl'
  render: ->
    @$el.html(Focus.template(@template)(@model.toJSON()))
    @

class UserModel extends Backbone.Model
  defaults:
    photo: ''
    fullname: ''
    id: -1
    slug: ''

  profileImage: ->
    view = new ProfileView model: @
    view.render()

class UserCollection extends Backbone.Collection
  url: -> "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/userprofile"
  model: UserModel

  parse: (response) ->
    response.object_list

  ###
  # Override default get(), if model does not exist in collection, try to 
  # query API for it.
  ###
  get: (id) ->
    user = super
    return user if user?
    # user doesn't exist, lets fetch it and add to collection
    user = new @model id: id
    @add user
    user.fetch
      # TODO: may need a better way to show an error with fetching a user
      error: =>
        @remove user
        null
    user

window.namespace 'Crp', (exports, top) ->
  exports.UserModel = UserModel
  exports.UserCollection = UserCollection
