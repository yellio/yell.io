angular.module('yellio')
  .directive 'localVideo', ->
    templateUrl: 'partials/local-video.html'
    restrict: 'AE'
    replace: yes
    scope:
      videoSrc: '=source'
