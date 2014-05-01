angular.module('yellio')
  .controller 'RoomCtrl', ($scope, $routeParams) ->
    $scope.name = $routeParams.name
