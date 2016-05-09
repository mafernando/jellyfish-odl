module JellyfishOdl
  module Service
    class RouterV4 < ::Service::Compute
      def actions
        actions = super.merge :terminate

        # determine if action is available

        actions
      end

      def provision
        # SUCCESS OR FAIL NOTIFICATION
        self.status = ::Service.defined_enums['status']['running']
        self.status_msg = 'running'
        self.save
      end

      def start
      end

      def stop
      end

      def terminate
      end

      private

      def client
        @client ||= provider.settings
      end
    end
  end
end
