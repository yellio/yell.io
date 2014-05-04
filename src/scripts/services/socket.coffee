angular.module('yellio')
  .factory 'socket', ($rootScope) ->
    socket = io.connect 'ws://192.168.1.3:3000'

    on: (event, cb) ->
      socket.on event, ->
        args = arguments
        $rootScope.$apply ->
           cb.apply socket, args

    emit: (event, data, cb) ->
      socket.emit event, data, ->
        args = arguments
        $rootScope.$apply ->
          if cb
            cb.apply socket, args
