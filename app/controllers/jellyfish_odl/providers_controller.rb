module JellyfishOdl
  class ProvidersController < JellyfishOdl::ApplicationController
    after_action :verify_authorized

    def network_topology
      authorize :odl
      render json: provider.network_topology
    end

    def shift_drop_rule
      authorize :odl
      render json: provider.shift_drop_rule
    end

    def add_rule
      authorize :odl
      render json: provider.add_rule
    end

    def edit_rule
      authorize :odl
      render json: provider.edit_rule(params[:rule])
    end

    def remove_rule
      authorize :odl
      render json: provider.remove_rule(params[:rule_num])
    end

    private

    def provider
      @provider ||= ::Provider.find params[:id]
    end
  end
end
