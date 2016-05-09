module JellyfishOdl
  module Product
    class RouterV4 < ::Product
      def order_questions
        [
        ]
      end

      def service_class
        'JellyfishOdl::Service::RouterV4'.constantize
      end

      private

      def init
        super
        self.img = 'products/odl.png'
      end
    end
  end
end
