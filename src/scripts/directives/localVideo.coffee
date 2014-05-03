angular.module('yellio')
  .directive 'localVideo', (ngRTC, $sce) ->
    templateUrl: 'partials/local-video.html'
    restrict: 'E'
    link: (scope, element, attrs) ->

