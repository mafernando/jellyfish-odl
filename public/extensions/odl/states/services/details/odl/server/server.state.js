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

    vm.toBeAdded = toBeAdded;

    vm.activate = activate;

    activate();

    function activate() { }

    function toBeAdded(action, rule){
      //etl_rule = {}
      //for(rule_key in rule){
      //  etl_rule[rule_key] = rule;
      //}
      switch (action) {
        case 'update':
          console.log(action+' functionality to be added')
          break;
        case 'delete':
          console.log(action+' functionality to be added')
          break;
        default:
          console.log('unknown '+action+' functionality to be added')
          break;
      }
    }

    function handleResults(data) {
      console.log(data);

      vm.response = data;

      // CREATE EMPTY FIREWALL RULES STATE
      var firewall_rules = [];

      // EXTRACT RULES
      try {
        // GET FIREWALL POLICIES
        var policies = data[0]['vyatta-security-firewall:name'];

        // RETRIEVE CURRENT POLICY - TEST
        var policy = policies[0]; // THERE COULD BE MULTIPLE POLICIES
        var tagnode = policy['tagnode'];

        // PARSE TEST POLICY RULES AND ADD TO FIREWALL RULES
        var rules = policy['rule'];
        for(var i=0; i<rules.length;i++){
          var rule = rules[i];
          rule['policy'] = tagnode;
          firewall_rules.push(rule);
        }
      }catch (Exception){
        console.log(Exception)
      }

      // ADD FIREWALL RULES TO VIEW MODEL
      vm.firewall_rules = firewall_rules;
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
