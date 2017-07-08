angular.module('MyApp')
  .controller('HomeCtrl', ['$scope', '$rootScope', '$state', '$auth', '$q', 'Task', '$uibModal', '$interval', 'uiCalendarConfig', function($scope, $rootScope, $state, $auth, $q, Task, $uibModal, $interval, uiCalendarConfig) {
    $scope.formData = { searchTerm: '' };
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
        forceEventDuration: true,
        slotDuration: "00:15:00",
        nowIndicator:true,
        editable: true,
        eventClick: function(event) {
        // opens events in a popup window
          // window.open(event.url);
          $scope.openTask(event);
          return false;
        },
        eventDrop: function(event, delta, revertFunc, jsEvent, ui, view) {
          console.log(event);
          console.log(delta);
          // alert(event.start_date);
          // alert(event.end_date);
          // alert(delta);
          var start_moment = moment(moment(event.start_date) + delta);
          var due_moment = moment(moment(event.end_date) + delta);
          console.log(start_moment);
          console.log(due_moment);
          // alert(start_moment);
          // alert(due_moment);
          // alert(start_moment.toDate());
          // alert(due_moment.toDate());

          Task.get(event.id).then(function (task) {
            task.start_date = start_moment.toDate();
            task.end_date = due_moment.toDate();
            task.due_date = due_moment.toDate();

            task.save().then(function(data) {
              event.start_date = start_moment;
              event.end_date = due_moment;
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
        eventResize: function( event, delta, revertFunc, jsEvent, ui, view ) {
          console.log(event);
          console.log(delta);

          var start_moment = moment(event.start_date);
          var due_moment = moment(moment(event.end_date) + delta);
          console.log(start_moment);
          console.log(due_moment);
          // alert(start_moment);
          // alert(due_moment);
          // alert(start_moment.toDate());
          // alert(due_moment.toDate());

          Task.get(event.id).then(function (task) {
            task.start_date = start_moment.toDate();
            task.end_date = due_moment.toDate();
            task.due_date = task.end_date;
            // console.log(task);
            task.save().then(function(data) {
              event.start_date = start_moment;
              event.end_date = due_moment;
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
        }, 120 * 60 * 1000);
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
      // console.log(startDate);
      // console.log(endDate);

      var event = { id: task.id,
        title: task.project_name + '\r\n' + task.name,
        start: task.start_date,
        start_date: task.start_date,
        end: task.end_date,
        end_date: task.end_date,
        due_date: task.due_date,
        allDay: task.all_day,
        all_day: task.all_day,
        description: task.description,
        name: task.name,
        project_name: task.project_name,
        periodHours: (moment(task.end_date).diff(moment(task.start_date), 'hours', true)),
        url: task.external_url };

      if (task.completed)
        event.color = 'green';

      // console.log(event);

      return event;
    };

    function filterEvents(events,searchTerm) {
      var filteredEvents = [];
      for (var i = 0; i < events.length; i++) {
        var event = events[i];
        var matches = event.title.match(searchTerm);
        if (matches)
          filteredEvents.push(event);
      }
      return filteredEvents;
    };

    function fillTasks(startDate, endDate, forceRetrieve) {
      $scope.loadingEvents = true;
      var params = { startDate: startDate, endDate: endDate };
      if (forceRetrieve)
        params.retrieve = forceRetrieve;
      Task.query(params).then(function(data) {
        $scope.tasks = data;
        var events = $scope.tasks.map(function(item) {
          return taskToEvent(item);
        });
        if ($scope.formData.searchTerm && $scope.formData.searchTerm.length > 0) {
          events = filterEvents(events, $scope.formData.searchTerm);
        }
        var hoursSum = 0;
        for (var i = 0; i < events.length; i++) {
          var event = events[i];
          if (!event.allDay) {
            var hours = moment(event.end).diff(moment(event.start), 'hours', true);
            if (!isNaN(hours))
              hoursSum += hours;
          }
        }
        $scope.hoursSum = hoursSum;

        if ($scope.eventsSource.length > 0)
          $scope.eventsSource.splice(0, 1)
        $scope.eventsSource.push(events);
        $scope.events = events;
        $scope.loadingEvents = false;
      });
    };

    function reloadTasks(view, forceRetrieve) {
      console.log('reloadTasks reached');
      if (forceRetrieve === undefined)
        forceRetrieve = false;

      if (!view)
        view = uiCalendarConfig.calendars.tasksCalendar.fullCalendar('getView');
      var newStart = null;
      var newEnd = null;
      if (view.start && view.end) {
        newStart = moment(view.start.toISOString()).local().toDate();
        newEnd = moment(view.end.toISOString()).local().toDate();
      } else {
        newStart = moment(view.intervalStart.toISOString()).local().toDate();
        newEnd = moment(view.intervalEnd.toISOString()).local().toDate();
      }
      fillTasks(newStart, newEnd, forceRetrieve);
    }

    if ($scope.isAuthenticated()) {
      successLogged($rootScope.user);
    } else {
      startInterval();
    }

    $scope.refreshTasks = function() {
      $scope.showTableResults = false;
      reloadTasks(null, true);
    };

    $scope.showiCal = false;
    $scope.toggleICal = function() {
      $scope.showiCal = !$scope.showiCal;
    };

    $scope.openTask = function(task) {
      var modalInstance = $uibModal.open({
        animation: true,
        size: 'lg',
        templateUrl: 'tasks/modal.html',
        controller: 'TaskModalCtrl',
        resolve: {
          currentTask: function() {
            return task;
          }
        }
      });

      modalInstance.result.then(function (deletedTask) {
        if (deletedTask) {
          reloadTasks();
        }
      }, function () {
        console.log('Modal dismissed at: ' + new Date());
      });
    }

    // var isMob = window.cordova !== undefined;
    // if (isMob)
    //   document.addEventListener("deviceready", validate, false);
    // else
    //   validate();
  }]);
