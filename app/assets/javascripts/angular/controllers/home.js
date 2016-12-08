angular.module('MyApp')
  .controller('HomeCtrl', function($scope, $rootScope, $state, $auth, $q, Task, $uibModal) {
    $scope.viewChanged = function( view, element ) {
      var newStart = moment(view.intervalStart.toISOString()).local().toDate();
      var newEnd = moment(view.intervalEnd.toISOString()).local().toDate();
      fillTasks(newStart, newEnd);
    };

    /* config object */
    $scope.uiConfig = {
      calendar:{
        viewRender: $scope.viewChanged,
        header:{
          left: 'month basicWeek basicDay',
          center: 'title',
          right: 'today prev,next'
        },
        eventClick: function(event) {
        // opens events in a popup window
          window.open(event.url);
          return false;
        },
        
        loading: function(bool) {
          $('#loading').toggle(bool);
        }
      }
    };
    $scope.eventsSource = [];

    function successLogged(data) {
      console.log('logged');
      reloadTasks();
    };

    $scope.loginWithTrello = function() {
      $auth.authenticate('trello')
        .then(successLogged)
        .catch(function(resp) {
          console.log(resp);
          //logOrRegisterWithUUID();
        });
    };

    $scope.isAuthenticated = function() {
      return $auth.userIsAuthenticated();
    };

    function validate() {
      $auth.validateUser().then(successLogged, function(result) {
        // deixa a pessoa fazer seu próprio login
        // setTimeout(logOrRegisterWithUUID, 100);
        return result;
      });
    }

    function taskToEvent(task) {
      var event = { id: task.id, title: task.project_name + '\r\n' + task.name, description: task.description, start: moment(task.due_date).toDate(), allDay: true, url: task.external_url };
      if (task.completed)
        event.color = 'green';
      return event;
    }

    function fillTasks(startDate, endDate) {
      Task.query({startDate: startDate, endDate: endDate}).then(function(data) {
        $scope.tasks = data;
        var events = $scope.tasks.map(function(item) {
          return taskToEvent(item);
        });
        if ($scope.eventsSource.length > 0)
          $scope.eventsSource.splice(0, 1)
        $scope.eventsSource.push(events);
        $scope.events = events;
      });
    }

    function reloadTasks() {
      var startDate = moment(new Date()).startOf('month').toDate();
      var endDateMoment = moment(startDate); // moment(...) can also be used to parse dates in string format
      endDateMoment.add(1, 'months');
      endDate = endDateMoment.toDate();

      fillTasks(startDate, endDate);
    }
    
    reloadTasks();

    $scope.refreshTasks = function() {
      reloadTasks();
    };

    $scope.newProject = function() {
      var modalInstance = $uibModal.open({
        animation: true,
        size: 'lg',
        templateUrl: 'projects/new.html',
        controller: 'NewProjectCtrl'
      });

      modalInstance.result.then(function (newGroupRequest) {
        alert('projeto criado com sucesso!');
        reloadTasks();
      }, function () {
        reloadTasks();
      });
    }

    // var isMob = window.cordova !== undefined;
    // if (isMob)
    //   document.addEventListener("deviceready", validate, false);
    // else
    //   validate();
  });
