angular.module('yellio')
  .directive 'localVideo', ->
    templateUrl: 'partials/local-video.html'
    restrict: 'E'
    link: (scope, element, attrs) ->

