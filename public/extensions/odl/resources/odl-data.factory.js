(function() {
  'use strict';

  angular.module('app.resources')
    .factory('OdlData', OdlDataFactory);

  /** @ngInject */
  function OdlDataFactory($resource) {
    var base = '/api/v1/odl/providers/:id/:action';
    var OdlData = $resource(base, {action: '@action', id: '@id'});

    OdlData.networkTopology = networkTopology;

    return OdlData;

    function networkTopology(id) {
      return OdlData.query({id: id, action: 'network_topology'}).$promise;
    }
  }
})();
