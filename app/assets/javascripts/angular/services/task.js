angular.module('MyApp')
  .factory('Task', ['$resource', '$auth', 'railsResourceFactory', 'config', 'railsSerializer',
    function($resource, $auth, railsResourceFactory, config, railsSerializer) {
      var resource = railsResourceFactory({
        url: config.API_URL + '/tasks', 
        name: 'task',
        interceptors: ['setPagingHeadersInterceptor'],
        serializer: railsSerializer(function () {
            this.serializeWith('due_date', 'dateSerializer');
            this.serializeWith('start_date', 'dateSerializer');
        })
      });

      return resource;
  }]);

angular.module('MyApp').factory('dateSerializer' , function(  ) {
     function DateSerializer () {
     }
     DateSerializer.prototype.serialize = function(value) {
         return value;
     };
     DateSerializer.prototype.deserialize = function(jsonDate) {
         if (jsonDate) {
            if (angular.isDate(jsonDate)) {
                 return jsonDate;
            } else {
             return new Date(jsonDate);
            }
         } else {
            return jsonDate;
         }
     };
     return DateSerializer;
});