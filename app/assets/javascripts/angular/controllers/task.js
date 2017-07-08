angular.module('MyApp')
  .controller('TaskModalCtrl', ['$scope', '$rootScope', '$uibModalInstance', '$auth', '$q', 'Task', 'currentTask', function($scope, $rootScope, $uibModalInstance, $auth, $q, Task, currentTask) {
      $scope.task = currentTask;

      $scope.close = function () {
        $uibModalInstance.dismiss('cancel');
      };

      $scope.delete = function() {
        Task.get($scope.task.id).then(function (task) {
          // console.log(task);
          task.delete().then(function() {
            $uibModalInstance.close(true);
          }, function(error) {
            console.log(error);
          })
        });
      }
    }
  ]);
