angular.module('yellio')
  .directive 'remoteVideo', ->
    templateUrl: 'partials/remote-video.html'
    restrict: 'AE'
    scope:
      videoSrc: '=source'
