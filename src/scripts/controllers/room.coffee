angular.module('yellio')
  .controller 'RoomCtrl', ($scope, $routeParams, socket, rtc, $sce) ->

    $scope.cameraError = no
    $scope.localVideoSrc = ''
    $scope.user = {}
    $scope.remoteVideos = {}
    $scope.roomName = $routeParams.name

    rtc.prepareToCall (err, localVideoUrl) ->
      $scope.$apply ->
        if err then $scope.cameraError = yes
        else $scope.localVideoSrc = localVideoUrl

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

    rtc.onCall = rtc.acceptCall

    rtc.onCallStarted = (callData) ->
      url = rtc.getStreamUrl callData.stream
      $scope.remoteVideos[callData.username] = url
