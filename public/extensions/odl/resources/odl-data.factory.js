(function() {
  'use strict';

  angular.module('app.resources')
    .factory('OdlData', OdlDataFactory);

  /** @ngInject */
  function OdlDataFactory($resource) {
    var base = '/api/v1/odl/providers/:id/:action';
    var OdlData = $resource(base, {action: '@action', id: '@id'},{
      'update': {
        method: 'PUT',
        isArray: false
      }
    });

    OdlData.networkTopology = networkTopology;
    OdlData.addRule = addRule;
    OdlData.editRule = editRule;
    OdlData.removeRule = removeRule;

    return OdlData;

    function networkTopology(id) {
      return OdlData.query({id: id, action: 'network_topology'}).$promise;
    }

    function addRule(id, rule) {
      return OdlData.save({id: id, action: 'add_rule', rule: rule}).$promise;
    }

    function editRule(id, rule) {
      return OdlData.save({id: id, action: 'edit_rule', rule: rule}).$promise;
    }

    function removeRule(id, rule) {
      return OdlData.delete({id: id, action: 'remove_rule'}).$promise;
    }

  }
})();
