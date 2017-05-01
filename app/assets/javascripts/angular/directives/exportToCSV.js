angular.module('MyApp')
  .directive('exportTableToCsv',function() {
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        var el = element[0];
        element.bind('click', function(e){
          try {
            e.preventDefault();
          } catch (ex) {}

          var table = $(attrs.exportToCsv)[0];
          var csvString = '';
          for(var i=0; i<table.rows.length;i++){
            var rowData = table.rows[i].cells;
            for(var j=0; j<rowData.length;j++){
              csvString = csvString + rowData[j].innerText + ",";
            }
            csvString = csvString.substring(0,csvString.length - 1);
            csvString = csvString + "\n";
          }
          csvString = csvString.substring(0, csvString.length - 1);
          var a = $('<a/>', {
              style:'display:none',
              href:'data:application/octet-stream;base64,'+btoa(csvString),
              download:'dados.csv'
          }).appendTo('body')
          a[0].click()
          a.remove();
        });
      }
    }
  })
  .directive('exportListToCsv',function() {
    return {
      restrict: 'A',
      scope: {
            listAction: '&'
            attributeListMethod: '&'
        },
      link: function (scope, element, attrs) {
        var el = element[0];
        element.bind('click', function(e){
          a.remove();
          try {
            e.preventDefault();
          } catch (ex) {}

          scope.$apply(function() {
            var list = scope.$eval(attrs.listAction);
            var csvString = '';

            for(var i=0; i<list.length;i++){
              var row = list[i];
              var rowData = scope.$eval(attrs.attributeListMethod + '(row)');
              for(var j=0; j<rowData.length;j++){
                csvString = csvString + rowData[j] + ",";
              }
              csvString = csvString.substring(0,csvString.length - 1);
              csvString = csvString + "\n";
            }

            csvString = csvString.substring(0, csvString.length - 1);
            var a = $('<a/>', {
                style:'display:none',
                href:'data:application/octet-stream;base64,'+btoa(csvString),
                download:'dados.csv'
            }).appendTo('body')
            a[0].click()

          });
        });
      }
    }
  });