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

    vm.activate = activate;

    activate();

    function activate() {
    }
  }
})();
