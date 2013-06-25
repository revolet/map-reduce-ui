'use strict';

// Declare app level module which depends on filters, and services
angular.module('MapReduce', ['MapReduce.filters', 'MapReduce.services', 'MapReduce.directives', 'MapReduce.controllers']).
    config(['$routeProvider', function($routeProvider) {
        $routeProvider.when('/', {templateUrl: 'app/partials/mapreduce.html', controller: 'MapReduceCtrl'});
        $routeProvider.otherwise({redirectTo: '/'});
    }])
;


