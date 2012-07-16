# Class that will handle the Socket.IO communication
class Socket
  constructor: (options) ->
    @host = options.host if options.host?
    @port = options.port if options.port?
    @pubsub = options.pubsub if options.pubsub?

    if @host?
      @connect

  connect: (options) ->
    socket_url = 'http://'
    socket_url += if options.host then options.host else @host
    socket_url += ':' + options.port if options.port? or @port?

    @socket = io.connect socket_url

    @callbacks()

  callbacks: ->
    @socket.on 'connect', ->
      @pubsub.trigger 'socket.connected'

    @socket.on 'disconnect', ->
      @pubsub.trigger 'socket.disconnected'

    @socket.on 'message', (msg) ->
      event_name = 'socket.' + msg.type
      log '<<~- ', data: msg
      @pubsub.trigger event_name, msg

  send: (data) ->
    log '-~>> ', data: data
    @socket.json.send data

