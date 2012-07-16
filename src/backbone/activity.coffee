class ActivityModel extends Backbone.Model
  defaults:
    actor_id: -1
    action: ''
    created_at: ''
    id: -1

  initialize: (options) ->
    ''

  clear: ->
    @destroy()
    @view.remove()

class ActivityCollection extends Backbone.Collection
  model: ActivityModel
  keyName: 'activities'
  comparator: (model) -> -1 * model.get 'created_at'

class ActivityRowView extends Crp.View
  className: 'activity-unit'
  template: 'activity-row-tmpl'

  initialize: (options) ->
    @model.on 'change', @render, @
    @model.on 'destroy', @clear, @

    @

  clear: (e) ->
    @remove()

  render: (e) ->
    data = @model.toJSON()
    author = @model.get 'actor_id'

    data.timestamp = @model.humanize 'created_at'
    data.author = @users.get(author).toJSON()

    @$el.html(Focus.template(@template)(data))
    @

class ActivityListView extends Crp.ListView
  view: ActivityRowView
  initialize: (options) ->
    @pubsub.on 'global.activity.add', @newRow
    @

  render: ->
    @$el.html('')
    # TODO: Don't hardcode max items to show
    @collection.each (model, index) =>
      if index < 15
        @addRow model
    @

window.namespace 'Crp', (exports) ->
  exports.ActivityModel = ActivityModel
  exports.ActivityCollection = ActivityCollection
  exports.ActivityRowView = ActivityRowView
  exports.ActivityListView = ActivityListView


