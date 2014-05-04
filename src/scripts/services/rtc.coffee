angular.module('yellio')
  .service 'rtc', ($sce, socket) ->

    self = this
    localStream = {}

    #Normalization
    PeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection
    SessionDescription = window.RTCSessionDescription || window.mozRTCSessionDescription || window.webkitRTCSessionDescription
    RTCIceCandidate = window.mozRTCIceCandidate || window.webkitRTCIceCandidate || window.RTCIceCandidate
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia

    @getStreamUrl = (stream) ->
      url = window.URL.createObjectURL stream
      $sce.trustAsResourceUrl(url)

    @getLocalMediaStream = (resources, cb) ->
      errorCallback = (err) ->
        cb err
      successCallback = (localMediaStream) ->
        cb null, localMediaStream
      navigator.getUserMedia resources, successCallback, errorCallback


    #Peer Connection initialization

    class Peer
      constructor: ->
        @pc = new PeerConnection(iceServers: [url: "stun:stun.l.google.com:19302"])
        @pc.addStream localStream

        @pc.onicecandidate = ((event) ->
          if (!@pc || !event || !event.candidate)
            return
          candidate = event.candidate
          socket.emit 'send candidate', candidate
        ).bind this

        socket.on 'ice candidate', ((candidate) ->
          @pc.addIceCandidate new RTCIceCandidate(candidate)
        ).bind this


        socket.on 'call accepted', ((desc) ->
          @pc.setRemoteDescription new RTCSessionDescription(desc)
        ).bind this


        @pc.onaddstream = ((event) ->
          return unless event
          self.onCallStarted self.getStreamUrl(event.stream)
        ).bind this

      call: ->
        @pc.createOffer ((desc) ->
          @pc.setLocalDescription desc
          socket.emit 'call request', desc
        ).bind this

      answer: (offerDesc) ->
        @pc.setRemoteDescription new SessionDescription(offerDesc)
        @pc.createAnswer ((desc) ->
          @pc.setLocalDescription desc
          socket.emit 'call accept', desc
        ).bind this


    socket.on 'incoming call', (desc) ->
      self.onCall desc

    @acceptCall = (offerDesc) ->
      peer = new Peer
      peer.answer(offerDesc)

    @initiateCall = ->
      peer = new Peer
      peer.call()

    @onCall = ->

    @onHang = ->

    @onCallStarted = ->

    @rejectCall = -> alert 'call rejected'

    @prepareToCall = (cb) ->
      self.getLocalMediaStream {audio: yes, video: yes}, (err, stream) ->
        if err then cb err
        localStream = stream
        cb null, self.getStreamUrl(localStream)

    return @
