module JellyfishOdl
  class ProvidersController < JellyfishOdl::ApplicationController
    after_action :verify_authorized

    def network_topology
      authorize :odl
      render json: provider.network_topology
    end

    private

    def provider
      @provider ||= ::Provider.find params[:id]
    end
  end
end
