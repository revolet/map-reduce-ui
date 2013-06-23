'use strict';

/* Controllers */

angular.module('MapReduce.controllers', []).
    controller('MapReduceCtrl', ['$scope', 'WebSocket', function($scope, socket) {
        $scope.jobs = [{id: 'Loading...' }];

        socket.onopen = function() {  
            console.log('Socket Status: '+socket.readyState+' (open)');  
            socket.send('Woot!');
        }

        socket.onmessage = function(msg) {  
            console.log('Received: '+msg.data);  
            var jobs = angular.fromJson( decodeURIComponent( escape(msg.data) ) );
            
            $scope.jobs = jobs;
            
            $scope.$apply();
        }  

        socket.onclose = function() {  
            console.log('Socket Status: '+socket.readyState+' (Closed)');  
        }
    }])
;

