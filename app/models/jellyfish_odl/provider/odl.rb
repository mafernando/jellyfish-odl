module JellyfishOdl
  module Provider
    class Odl < ::Provider
      class SimpleClient
        def initialize
          true
        end

        def settings
          {}
        end
      end

      private

      def client
        # TODO: IMPLEMENT DOCKER CLIENT - https://docs.docker.com/reference/api/docker_remote_api/
        @client ||= SimpleClient.new
      end
    end
  end
end
