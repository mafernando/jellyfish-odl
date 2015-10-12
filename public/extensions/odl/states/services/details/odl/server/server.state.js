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
  function StateController(service) {
    var vm = this;

    vm.title = '';

    vm.service = service;

    vm.refreshNodes = refreshNodes;

    vm.activate = activate;

    activate();

    function activate() { }

    function refreshNodes(){
        // THIS IS WHERE REST CALLS TO JF API WILL GO
      vm.response = [
        { id: 55, spent: 1, foobar: 'fifty-five', host: 'odl_controller', ip: '192.168.99.100', description: 'ODL CONTROLLER', actions: 'x' },
        { id: 66, spent: 2, foobar: 'sixty-six', host: 'host1', ip: '10.0.0.1', description: 'HOST 1', actions: 'x' },
        { id: 77, spent: 3, foobar: 'seventy-seven', host: 'host2', ip: '10.0.0.2', description: 'HOST 2', actions: 'x' }
      ];
      console.log('refreshed')
    }
  }
})();
