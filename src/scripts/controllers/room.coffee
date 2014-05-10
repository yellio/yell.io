angular.module('yellio')
  .controller 'RoomCtrl', ($scope, $routeParams, socket, rtc, $sce) ->

    $scope.cameraError = no
    $scope.user = {}
    $scope.remoteVideos = {}
    $scope.remoteScreens = {}
    $scope.roomName = $routeParams.name

    $scope.$on '$destroy', ->
      socket.emit 'leave room'

    rtc.getWebcamStream (err, webcamStream) ->
      $scope.$apply ->
        if err then $scope.cameraError = yes
        else $scope.localVideoSrc = rtc.getStreamUrl webcamStream

    $scope.joinRoom = ->
      if $scope.loginForm.username.$valid
        $scope.user.name = $scope.username
        socket.emit 'join room',
          name: $scope.user.name
          room: $scope.roomName

    socket.on 'room info', (room) ->
      $scope.room = room

    socket.on 'user joined', (user) ->
      $scope.room[user.name] = user.id
      rtc.initiateCall(user.name)

    socket.on 'user disconnected', (username) ->
      delete $scope.room[username]
      delete $scope.remoteVideos[username]
      delete $scope.remoteScreens[username]

    rtc.onCall = rtc.acceptCall

    rtc.onCallStarted = (callData) ->
      url = rtc.getStreamUrl callData.stream
      $scope.$apply ->
        $scope.remoteVideos[callData.username] = url

    rtc.onScreenShare = (data) ->
      url = rtc.getStreamUrl data.stream
      $scope.$apply ->
        $scope.remoteScreens[data.username] = url

    $scope.shareScreen = rtc.shareScreen
