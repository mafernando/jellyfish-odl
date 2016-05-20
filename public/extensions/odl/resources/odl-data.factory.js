(function() {
  'use strict';

  angular.module('app.resources')
    .factory('OdlData', OdlDataFactory);

  /** @ngInject */
  function OdlDataFactory($resource) {
    var base = '/api/v1/odl/providers/:id/:action';
    var OdlData = $resource(base, {action: '@action', id: '@id'},{
      'save': {
        method: 'POST',
        isArray: true
      },
      'delete': {
        method: 'DELETE',
        isArray: true
      }
    });

    OdlData.networkTopology = networkTopology;
    OdlData.getAllFirewallRules = getAllFirewallRules;
    OdlData.enableVideoPolicy = enableVideoPolicy;
    OdlData.disableVideoPolicy = disableVideoPolicy;
    OdlData.addRule = addRule;
    OdlData.editRule = editRule;
    OdlData.removeRule = removeRule;
    OdlData.shiftDropRule = shiftDropRule;

    return OdlData;

    function networkTopology(id) {
      return OdlData.query({id: id, action: 'network_topology'}).$promise;
    }

    function getAllFirewallRules(id) {
      return OdlData.query({id: id, action: 'get_all_firewall_rules'}).$promise;
    }

    function enableVideoPolicy(id) {
      return OdlData.query({id: id, action: 'enable_video_policy'}).$promise;
    }

    function disableVideoPolicy(id) {
      return OdlData.query({id: id, action: 'disable_video_policy'}).$promise;
    }

    function shiftDropRule(id) {
      return OdlData.query({id: id, action: 'shift_drop_rule'}).$promise;
    }

    function addRule(id, rule) {
      return OdlData.save({id: id, action: 'add_rule', rule: rule}).$promise;
    }

    function editRule(id, rule) {
      return OdlData.save({id: id, action: 'edit_rule', rule: rule}).$promise;
    }

    function removeRule(id, rule_num, policy) {
      return OdlData.delete({id: id, action: 'remove_rule', rule_num: rule_num, policy: policy}).$promise;
    }

  }
})();
