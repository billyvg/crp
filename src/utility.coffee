window.namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 5
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

window.namespace 'Focus', (exports, top) ->
  exports.template = (selector) =>
    tmpl = $('#' + selector).html()
    _.template(tmpl)

window.namespace 'Crp', (exports, top) ->
  exports.PubSub = _.extend {}, Backbone.Events

_.extend Backbone.Model.prototype,
  ###
  # Helper method that uses moment.js to return a human-readable timestamp.
  ###
  humanize: (attribute) ->
    moment.unix(@get attribute).fromNow()

_oldSync = Backbone.sync
Backbone.sync = (method, model, options) ->
  ajax = _oldSync.apply @, arguments
  if method is 'update'
    ajax.done (resp) ->
      model.set resp, silent: true
  ajax
