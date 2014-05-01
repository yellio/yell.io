angular.module('yellio')
  .controller 'HomeCtrl', ($scope, socket) ->

    socket.on 'availiable rooms', (rooms) ->
      $scope.rooms = for name, users of rooms
        name: name
        numberOfUsers: Object.keys(users).length
