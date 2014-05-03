angular.module('yellio')
  .controller 'RoomCtrl', ($scope, $routeParams, socket, ngRTC, $sce) ->

    $scope.formShown = yes
    $scope.user = name: 'anon'
    $scope.room = {}
    $scope.videos = []
    $scope.messages = []
    $scope.localVideoSrc = ''
    streamToAttach = {}
    pc = {}

    ngRTC.getLocalMediaStream {video: true, audio: true}, (err, stream) ->
      url = window.URL.createObjectURL stream
      pc = new ngRTC.PeerConnection(iceServers: [url: "stun:stun.l.google.com:19302"])

      pc.addStream stream
      $scope.$apply ->
        $scope.localVideoSrc = $sce.trustAsResourceUrl(url)

      pc.onaddstream = (event) ->
        return unless event
        url = window.URL.createObjectURL event.stream
        $scope.videos.push $sce.trustAsResourceUrl(url)

      pc.onicecandidate = (event) ->
        if (!pc || !event || !event.candidate)
          return
        candidate = event.candidate
        socket.emit 'send candidate', candidate



    $scope.joinRoom = ->
      if $scope.loginForm.username.$valid
        $scope.user.name = $scope.username
        socket.emit 'join room',
          name: $scope.user.name
          room: $routeParams.name
          description: 'desc'
        $scope.formShown = no


    socket.on 'room info', (room) ->
      $scope.room = room
      numberOfUsers = Object.keys(room).length
      if numberOfUsers > 1
        makeCall()

    socket.on 'user joined', (user) ->
      $scope.room[user.name] = user.resources

    socket.on 'user disconnected', (username) ->
      delete $scope.room[username]

    socket.on 'incoming call', (desc) ->
      $scope.messages.push 'incomming call'
      acceptCall desc

    socket.on 'call accepted', (desc) ->
      $scope.messages.push 'call was accepted'
      $scope.messages.push 'call started.....'
      receiveCall desc

    socket.on 'ice candidate', (candidate) ->
      pc.addIceCandidate new ngRTC.RTCIceCandidate(candidate)



    makeCall = ->
      pc.createOffer (desc) ->
        $scope.messages.push 'calling'
        pc.setLocalDescription desc
        socket.emit 'call request', desc

    acceptCall = (offerDesc) ->
      pc.setRemoteDescription new ngRTC.SessionDescription(offerDesc)
      pc.createAnswer (desc) ->
        $scope.messages.push 'accepting call'
        pc.setLocalDescription desc
        socket.emit 'call accept', desc

    receiveCall = (desc) ->
      pc.setRemoteDescription new RTCSessionDescription(desc)
