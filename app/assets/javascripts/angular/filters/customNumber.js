angular.module('MyApp')
  .filter('invariateNumber', [function() {
    return function(input) {
      var myNumber = input;
      var int = Math.floor(myNumber);
      var dec = Math.round(myNumber - int, 2);
      return ("" + int) + (dec > 10 ? ('.' + dec) : ('.0' + dec));
    };
  }]);