(function() {
  'use strict';

  angular.module('app.states')
    .run(appRun);

  /** @ngInject */
  function appRun(StateOverride) {
    StateOverride.override('services.details', function(service) {
      if ('JellyfishOdl::Service::Server' == service.type) {
        return {
          templateUrl: 'extensions/odl/states/services/details/odl/server/server.html',
          controller: StateController
        };
      }
    })
  }

  /** @ngInject */
  function StateController(service, OdlData) {
    var vm = this;

    vm.title = '';

    vm.service = service;

    vm.refreshNodes = refreshNodes;

    vm.activate = activate;

    activate();

    function activate() { }

    function handleResults(data) {
      console.log(data);

      var firewall_rules = [];

      // GET FIREWALL POLICIES
      var policies = data[0]['vyatta-security-firewall:name'];

      // RETRIEVE CURRENT POLICY - TEST
      var policy = policies[0]; // THERE COULD BE MULTIPLE POLICIES
      var tagnode = policy['tagnode'];

      // PARSE TEST POLICY RULES
      var rules = policy['rule'];
      for(var i=0; i<rules.length;i++){
        var rule = rules[i];
        rule['policy'] = tagnode;
        firewall_rules.push(rule);
      }

      vm.firewall_rules = firewall_rules;
      vm.response = data;
    }

    function handleError(response) {
      console.log(response);
      vm.response = response;
    }

    function refreshNodes(){
      OdlData['networkTopology'](vm.service.provider.id).then(handleResults, handleError);
      vm.response = ''
    }
  }
})();
