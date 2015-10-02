module JellyfishOdl
  module Provider
    class SimpleClient < ::Provider
      def initialize
        true
      end

      def settings
        {}
      end
    end

    class Odl < ::Provider

      def network_topology
        [ { host: 'Host 1', ip: '10.0.0.1' }, { host: 'Host 2', ip: '10.0.0.2' } ]
      end

      private

      def client
        # TODO: IMPLEMENT DOCKER CLIENT - https://docs.docker.com/reference/api/docker_remote_api/
        @client ||= SimpleClient.new
      end
    end
  end
end
