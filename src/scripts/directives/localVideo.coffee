angular.module('yellio')
  .directive 'localVideo', ->
    templateUrl: 'partials/local-video.html'
    restrict: 'AE'
    scope:
      videoSrc: '=source'
      shareScreen: '&sharescreen'
