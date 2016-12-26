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
          left: 'month agendaWeek agendaDay',
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
        eventMouseover: function(calEvent, jsEvent) {
          var tooltip = '<div class="tooltipevent" style="padding:30px;min-width:200px;width:auto;max-width:60%;height:100px;background:#ccc;position:absolute;z-index:10001;">' + calEvent.title + '</div>';
          var $tooltip = $(tooltip).appendTo('body');

          $(this).mouseover(function(e) {
            $(this).css('z-index', 10000);
            $tooltip.fadeIn('500');
            $tooltip.fadeTo('10', 1.9);
          }).mousemove(function(e) {
            $tooltip.css('top', e.pageY + 10);
            $tooltip.css('left', e.pageX + 20);
          });
        },
        eventMouseout: function(calEvent, jsEvent) {
            $(this).css('z-index', 8);
            $('.tooltipevent').remove();
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
      var due_moment = moment(task.due_date);
      var allDay = false;
      var startDate = moment(due_moment).toDate();
      var endDate = moment(due_moment).add(1, 'h').toDate();
      // console.log(startDate);
      // console.log(endDate);

      var event = { id: task.id, title: task.project_name + '\r\n' + task.name, description: task.description, url: task.external_url };
      if (task.completed)
        event.color = 'green';

      var regexList = [
        { property: "name", regex: /\(([-+]?[0-9]*\.?[0-9]+)([hmd]?)\)(.*)/g },
        { property: "name", regex: /\(([-+]?[0-9]*\.?[0-9]+)\)(.*)/g },
        { property: "description", regex: /AllBoardsCalendar=>Time:\(([-+]?[0-9]*\.?[0-9]+)([hmd]?)\)(.*)/g },
        { property: "description", regex: /AllBoardsCalendar=>Time:\(([-+]?[0-9]*\.?[0-9]+)\)(.*)/g }
      ];

      var match = null;
      while (regexList.length > 0 && (!match || match == null)) {
        var currentRegex = regexList[0];
        regexList.splice(0, 1);

        match = currentRegex.regex.exec(task[currentRegex.property]);;
      }

      if (match && (match.length == 4 || match.length == 3)) {
        var delta = parseFloat(match[1]);
        if (isNaN(delta))
          delta = 1;

        var deltaType = 'h';
        var newName = task.name;
        if (match.length == 4) {
          deltaType = match[2];
          if (!deltaType || deltaType.length == 0)
            deltaType = 'h';  
          newName = match[3];
        } else {
          newName = match[2];
        }

        event.title = task.project_name + '\r\n' + newName;
        if (delta > 0) {
          endDate = moment(due_moment).add(delta, deltaType).toDate();
        } else {
          startDate = moment(due_moment).add(delta, deltaType).toDate();
          endDate = moment(due_moment).toDate();  
        }
      }

      event.start = startDate;
      event.end = endDate;
      event.allDay = moment(event.end).diff(moment(event.start), 'days', true) >= 1;

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
