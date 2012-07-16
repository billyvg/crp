API_URL = Focus.Constants.API_URL

describe 'Asset', ->
  describe 'Model initialized with an id of 1', ->
    model = null
    urlRoot = "#{ API_URL }/asset"

    beforeEach ->
      model = new Crp.AssetModel id: 1

    it 'should have an id of 1', ->
      expect(model.get('id')).toBe 1

    it 'should have default parameters for the other fields', ->
      model = new Crp.AssetModel()
      expect(model.get('title')).toBe ''
      expect(model.get('description')).toBe ''

    it 'should have the correct urlRoot', ->
      expect(Crp.AssetModel::urlRoot).toBe "#{ API_URL }/asset"


    describe 'when destroyed', ->
      beforeEach ->
        spyOn(model, 'destroy').andCallThrough()
        spyOn $, 'ajax'
        model.destroy()

      it 'should call the correct API Url', ->
        expect(model.destroy).toHaveBeenCalled()

        args = $.ajax.mostRecentCall.args[0]
        expect(args.dataType).toBe 'json'
        expect(args.type).toBe 'DELETE'
        expect(args.url).toBe "#{ urlRoot }/1"

  describe 'Single View', ->
    view = null

    beforeEach ->
      view = new Crp.AssetView()

    describe 'Backbone Events', ->
      it 'should handle "Follow" button when it is clicked.', ->
        selector = '.follow'
        spyOnEvent $(selector), 'click'
        $(selector).click()
        expect('click').toHaveBeenTriggeredOn $(selector)

