(function() {
  'use strict';

  angular.module('app.components')
    .run(initFields);

  /** @ngInject */
  function initFields(Forms) {

    Forms.fields('odl_versions', {
      type: 'select',
      templateOptions: {
        label: 'ODL Version',
        options: [
          {label: 'ODL Lithium', value: 'li'},
          {label: 'ODL Beryllium', value: 'be'}
        ]
      }
    });

    Forms.fields('router_versions', {
      type: 'select',
      templateOptions: {
        label: 'Router Version',
        options: [
          {label: '3.x', value: '3.x'},
          {label: '4.x', value: '4.x'}
        ]
      }
    });

    Forms.fields('policy_actions', {
      type: 'select',
      templateOptions: {
        label: 'Policy Action',
        options: [
          {label: 'Accept', value: 'accept'},
          {label: 'Drop', value: 'drop'}
        ]
      }
    });

    /** @ngInject */
    function OdlDataController($scope, OdlData, Toasts) {
      var provider = $scope.formState.provider;
      var action = $scope.options.data.action;

      // Cannot do anything without a provider
      if (angular.isUndefined(provider)) {
        Toasts.warning('No provider set in form state', $scope.options.label);
        return;
      }

      if (!action) {
        Toasts.warning('No action set in field data', $scope.options.label);
        return;
      }

      $scope.to.loading = OdlData[action](provider.id).then(handleResults, handleError);

      function handleResults(data) {
        $scope.to.options = data;
        return data;
      }

      function handleError(response) {
        var error = response.data;

        if (!error.error) {
          error = {
            type: 'Server Error',
            error: 'An unknown server error has occurred.'
          };
        }

        Toasts.error(error.error, [$scope.to.label, error.type].join('::'));

        return response;
      }
    }
  }
})();
