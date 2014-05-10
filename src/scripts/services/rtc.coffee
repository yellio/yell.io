angular.module('yellio')
  .service 'rtc', ($sce, socket) ->

######################################## Initialization ########################################
    self = this
    localWebcamStream = null
    localScreenShareStream = null
    peers = []

########################################  Normalization  ########################################
    PeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection
    SessionDescription = window.RTCSessionDescription || window.mozRTCSessionDescription || window.webkitRTCSessionDescription
    RTCIceCandidate = window.mozRTCIceCandidate || window.webkitRTCIceCandidate || window.RTCIceCandidate
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia


########################################      utils      ########################################
    @getStreamUrl = (stream) ->
      url = window.URL.createObjectURL stream
      $sce.trustAsResourceUrl(url)


    @getLocalMediaStream = (resources, cb) ->
      errorCallback = (err) ->
        cb err
      successCallback = (localMediaStream) ->
        cb null, localMediaStream
      navigator.getUserMedia resources, successCallback, errorCallback


    @getScreenShareStream = (cb) ->
      resources =
        audio: false
        video:
          mandatory:
            chromeMediaSource: 'screen'
            maxWidth: 1280
            maxHeight: 720
          optional: []

      self.getLocalMediaStream resources, (err, stream) ->
        if err then cb err
        localScreenShareStream = stream
        cb null, localScreenShareStream


    @getWebcamStream = (cb) ->
      self.getLocalMediaStream {audio: yes, video: yes}, (err, stream) ->
        if err then cb err
        localWebcamStream = stream
        cb null, localWebcamStream


########################################      Peer      ########################################

    class Peer
      constructor: (@username) ->
        @isCalling = no
        @pc = new PeerConnection(iceServers: [url: "stun:stun.l.google.com:19302"])
        @pc.addStream localWebcamStream
        @pc.addStream localScreenShareStream if localScreenShareStream

        @pc.onicecandidate = ((event) ->
          if (!@pc || !event || !event.candidate) then return
          if (event.switching) then return
          candidate = event.candidate
          socket.emit 'send candidate', {candidate:candidate, username: @username}
        ).bind this

        socket.on 'ice candidate', ((candidate) ->
          @pc.addIceCandidate new RTCIceCandidate(candidate)
        ).bind this

        socket.on 'call accepted', ((desc) ->
          @pc.setRemoteDescription new RTCSessionDescription(desc)
        ).bind this

        socket.on 'renegotiation', ((data) ->
          @answer(data.desc)
        ).bind this

        @pc.onaddstream = ((event) ->
          return unless event
          if @isCalling
            self.onScreenShare
              stream: event.stream
              username: @username
          else
            @isCalling = yes
            self.onCallStarted
              stream: event.stream
              username: @username
        ).bind this


      call: ->
        @pc.createOffer ((desc) ->
          @pc.setLocalDescription desc
          socket.emit 'call request', {desc: desc, username: @username}
        ).bind this

      renegotiate: ->
        @pc.createOffer ((desc) ->
          @pc.setLocalDescription desc
          socket.emit 'renegotiation request', {desc: desc, username: @username}
        ).bind this

      answer: (offerDesc) ->
        @pc.setRemoteDescription new SessionDescription(offerDesc)
        @pc.createAnswer ((desc) ->
          @pc.setLocalDescription desc
          socket.emit 'call accept', {desc: desc, username: @username}
        ).bind this


    socket.on 'incoming call', (data) ->
      self.onCall data


########################################    Public API    ########################################
    @acceptCall = (offer) ->
      peer = new Peer offer.username
      peers.push peer
      peer.answer(offer.desc)

    @initiateCall = (username) ->
      peer = new Peer username
      peers.push peer
      peer.call()

    @shareScreen = ->
      self.getScreenShareStream (err, stream) ->
        localScreenShareStream = stream
        for peer in peers
          peer.pc.addStream localScreenShareStream
          peer.renegotiate()


    @onCall = ->

    @onHang = ->

    @onCallStarted = ->

    @onScreenShare = ->

    @rejectCall = ->

    return @
