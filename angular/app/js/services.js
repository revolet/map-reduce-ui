'use strict';

/* Services */

// Demonstrate how to register services
// In this case it is a simple value service.
angular.module('MapReduce.services', []).
    factory('WebSocket', function() {
        var socket = new WebSocket('ws://localhost:3000/ws');
        
        return socket;
    }).
    value('version', '0.1')
;

