angular.module('yellio')
  .directive 'remoteVideo', ->
    templateUrl: 'partials/remote-video.html'
    restrict: 'AE'
    replace: yes
    scope:
      videoSrc: '=source'
