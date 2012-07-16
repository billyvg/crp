class TaskModel extends Backbone.Model
  defaults:
    finished: false

  initialize: (attributes) ->
    if attributes.actual_finish
      @set finished: true
    @

  clear: ->
    @destroy()
    @view.remove()

class TaskCollection extends Backbone.Collection
  model: TaskModel

  url: -> "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/task"

  parse: (response) ->
    response.object_list

  comparator: (model) ->
    return model.get 'order'

class TaskDeadlineCollection extends Backbone.Collection
  model: TaskModel
  keyName: 'tasks'

  url: -> "#{ Focus.Constants.API_URL }/workspace/#{ @workspace }/task_deadline"

  parse: (response) ->
    response.object_list

  comparator: (model) ->
    return model.get 'planned_deadline'

###
# View of a Task in the Task Deadline list
###
class TaskView extends Crp.View
  className: 'task-unit'
  template: 'task-tmpl'
  events:
    'click .add-assignee': 'addAssignee'
    'click input[type="checkbox"]': 'toggleFinished'

  initialize: (options) ->
    @model.on 'change', @render, @

  addAssignee: (e) ->
    @userac = new Crp.UserAutocompleteView()
    @$('.assignee').append(@userac.render().$el)
    @userac.on 'autocomplete.enter', (view) =>
      # TODO: temp
      @$('.assignee-list').append(' ' + view.getModel().get('fullname'))
      @model.set assignee_id: view.getModel().get('id')
      @model.save wait: true
    @

  # Checkbox next to Task title was clicked, toggle finished state
  toggleFinished: (e) ->
    # mark as incomplete
    if @model.get 'finished'
      @model.save
        finished: false
      ,
        silent: true
      @animateUnfinish.apply @, arguments

    # mark as finished
    else
      @model.save
        finished: true
      ,
        silent: true
      @animateFinished.apply @, arguments

  # animation for when a task is marked as finished
  animateFinished: (e) ->
    $(e.target).prop('checked', true)
    @$('.task-body').slideUp 250, () =>
      @$el.addClass 'finished'

  # animation for when a task is marked as unfinished
  animateUnfinish: (e) ->
    $(e.target).prop('checked', false)
    @$el.removeClass 'finished'
    @$('.task-body').slideDown 250


  render: (e) ->
    assignee_id = @model.get 'assignee_id'
    user = @users.get assignee_id
    taskTitle = @getFrom @tasks, @model.get('task_id'), 'title'

    data =
      fullname: if assignee_id? then user.get 'fullname' else 'Nobody'
      duedate: @model.humanize 'planned_deadline'
      taskTitle: taskTitle
      finishDate: @model.humanize 'actual_finish'

    super e, data

    # check if task is completed or not
    if @model.get('actual_finish')?
      @$el.addClass 'finished hide-body'
    @

class TaskListView extends Crp.ListView
  view: TaskView


window.namespace 'Crp', (exports) ->
  exports.TaskCollection = TaskCollection
  exports.TaskDeadlineCollection = TaskDeadlineCollection
  exports.TaskView = TaskView
  exports.TaskListView = TaskListView
  exports.TaskModel = TaskModel
