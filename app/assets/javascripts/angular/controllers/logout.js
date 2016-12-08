angular.module('MyApp')
  .controller('LogoutCtrl', ['$location', '$auth', 'toastr', function($location, $auth, toastr) {
    $auth.signOut()
      .then(function() {
        toastr.info('Desconectado do sistema com sucesso.');
        $location.path('/login');
      });
  }]);