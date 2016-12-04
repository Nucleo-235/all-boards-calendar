angular.module('MyApp')
  .factory('Task', ['$resource', '$auth', 'railsResourceFactory', 'config', 
    function($resource, $auth, railsResourceFactory, config) {
      var resource = railsResourceFactory({
        url: config.API_URL + '/tasks', 
        name: 'task',
        interceptors: ['setPagingHeadersInterceptor']
      });

      return resource;
  }]);