(function() {
  'use strict';

  angular.module('app.resources')
    .factory('OdlData', OdlDataFactory);

  /** @ngInject */
  function OdlDataFactory($resource) {
    var base = '/api/v1/odl/providers/:id/:action';
    var OdlData = $resource(base, {action: '@action', id: '@id'});

    OdlData.networkTopology = networkTopology;
    OdlData.addRule = addRule;
    OdlData.editRule = editRule;
    OdlData.removeRule = removeRule;

    return OdlData;

    function networkTopology(id) {
      return OdlData.query({id: id, action: 'network_topology'}).$promise;
    }

    function addRule(id) {
      return OdlData.query({id: id, action: 'add_rule'}).$promise;
    }

    function editRule(id) {
      return OdlData.query({id: id, action: 'edit_rule'}).$promise;
    }

    function removeRule(id) {
      return OdlData.query({id: id, action: 'remove_rule'}).$promise;
    }

  }
})();
