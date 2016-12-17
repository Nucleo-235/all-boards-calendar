angular.module('MyApp')
  .controller('HomeCtrl', ['$scope', '$rootScope', '$state', '$auth', '$q', 'Task', '$uibModal', '$interval', 'uiCalendarConfig', function($scope, $rootScope, $state, $auth, $q, Task, $uibModal, $interval, uiCalendarConfig) {
    $scope.viewChanged = function( view, element ) {
      reloadTasks(view);
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
        editable: true,
        eventClick: function(event) {
        // opens events in a popup window
          window.open(event.url);
          return false;
        },
        eventDrop: function(event, delta, revertFunc, jsEvent, ui, view) {
          console.log(event);
          console.log(delta);
          Task.get(event.id).then(function (task) {
            var due_moment = moment(moment(task.due_date) + delta);
            task.due_date = due_moment.toDate();
            console.log(task);
            task.save().then(function(data) {

            }, function(error) { 
              revertFunc();
            }) 
          });
        },
        loading: function(bool) {
          $('#loading').toggle(bool);
        }
      }
    };
    
    $scope.eventsSource = [];

    var intervalStarted = false;
    function startInterval() {
      if (!intervalStarted) {
        intervalStarted = true;
        console.log('interval started');
        $interval(function() {
          console.log('interval reached');
          reloadTasks();
        }, 10 * 60 * 1000);
      }
    };

    function successLogged(data) {
      startInterval();
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
    };

    function taskToEvent(task) {
      var event = { id: task.id, title: task.project_name + '\r\n' + task.name, description: task.description, start: moment(task.due_date).toDate(), allDay: true, url: task.external_url };
      if (task.completed)
        event.color = 'green';
      return event;
    };

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
    };

    function reloadTasks(view) {
      console.log('reloadTasks reached');

      if (!view)
        view = uiCalendarConfig.calendars.tasksCalendar.fullCalendar('getView');
      var newStart = moment(view.intervalStart.toISOString()).local().toDate();
      var newEnd = moment(view.intervalEnd.toISOString()).local().toDate();
      fillTasks(newStart, newEnd);
    }
    
    if ($scope.isAuthenticated()) {
      successLogged($rootScope.user);
    } else {
      startInterval();
    }

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
  }]);
