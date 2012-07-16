class AttachmentModel extends Backbone.Model
  defaults:
    attachment_url: ''
    attachemnt_id: -1
    downloads: 0
    filename: ''
    userprofile_id: -1

  initialize: (attributes) ->
    @

  clear: ->
    @destroy()
    @view.remove()

class AttachmentCollection extends Backbone.Collection
  model: AttachmentModel
  keyName: 'attachments'

  url: ->
    return "#{ Focus.Constants.API_URL }/attachments"

  parse: (response) ->
    response.object_list

###
# View of a Attachment in the Attachment List
###
class AttachmentView extends Crp.ListView
  template: 'attachment-tmpl'
  rowTemplate: 'attachment-row-tmpl'

  addRow: (model) ->
    tbody = @$el.find 'tbody'
    tbody.append Focus.template(@rowTemplate)(model.toJSON())
    @

  render: (e) ->
    @$el.html(Focus.template(@template)())
    @collection.map (model) =>
      @addRow model

window.namespace 'Crp', (exports) ->
  exports.AttachmentCollection = AttachmentCollection
  exports.AttachmentView = AttachmentView
  exports.AttachmentModel = AttachmentModel
