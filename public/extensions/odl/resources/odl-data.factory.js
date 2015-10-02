(function() {
  'use strict';

  angular.module('app.resources')
    .factory('OdlData', OdlDataFactory);

  /** @ngInject */
  function OdlDataFactory($resource) {
    var base = '/api/v1/odl/providers/:id/:action';
    var OdlData = $resource(base, {action: '@action', id: '@id'});

    // PLACEHOLDER FOR FUNCTIONS TO BE ADDED LATER

    return OdlData;
  }
})();
