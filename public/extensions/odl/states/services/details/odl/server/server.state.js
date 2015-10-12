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

    //vm.response = [];

    vm.refreshNodes = refreshNodes;

    vm.activate = activate;

    activate();

    function activate() { }

    function handleResults(data) {
      console.log(data);
      vm.response = data;
      return data;
    }

    function handleError(response) {
      console.log(response);
      vm.response = response;
      return response;
    }

    function refreshNodes(){
      OdlData['networkTopology'](2).then(handleResults, handleError);
      vm.response = ''
    }
  }
})();
