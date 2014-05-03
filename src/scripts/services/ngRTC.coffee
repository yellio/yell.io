angular.module('yellio')
  .factory 'ngRTC', ($sce) ->



    getUserMediaURL: (constraints, cb) ->

      @getLocalMediaStream constraints, (err, stream) ->
        if err
          cb err
        else
          url = window.URL.createObjectURL stream
          cb null, $sce.trustAsResourceUrl(url)



    getLocalMediaStream: (constraints, cb) ->

      navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia

      errorCallback = (err) ->
        cb err

      successCallback = (localMediaStream) ->
        cb null, localMediaStream

      navigator.getUserMedia constraints, successCallback, errorCallback

    PeerConnection: window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection

    SessionDescription: window.RTCSessionDescription || window.mozRTCSessionDescription || window.webkitRTCSessionDescription

    RTCIceCandidate: window.mozRTCIceCandidate || window.webkitRTCIceCandidate || window.RTCIceCandidate
