angular.module('yellio')
  .controller 'RoomCtrl', ($scope, $routeParams, socket) ->

    $scope.formShown = yes
    $scope.roomName = $routeParams.name

    $scope.joinRoom = ->
      if $scope.loginForm.username.$valid
        socket.emit 'join room',
          name: $scope.username
          room: $scope.roomName
          resources: 'lel'
        $scope.formShown = no

    socket.on 'room info', (room) ->
      $scope.room = room

    socket.on 'user joined', (user) ->
      $scope.room[user.name] = user.resources

    socket.on 'user disconnected', (username) ->
      delete $scope.room[username]
