angular.module('yellio')
  .directive 'remoteVideo', ->
    templateUrl: 'partials/remote-video.html'
    restrict: 'AE'
    scope:
      videoSrc: '=source'
    link: (scope, elem, attrs) ->
      scope.fullScreen = off
      scope.toggleFullScreen = -> scope.fullScreen = if scope.fullScreen then off else on
