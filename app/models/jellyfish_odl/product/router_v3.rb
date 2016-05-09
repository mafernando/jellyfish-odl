module JellyfishOdl
  module Product
    class RouterV3 < ::Product
      def order_questions
        [
        ]
      end

      def service_class
        'JellyfishOdl::Service::RouterV3'.constantize
      end

      private

      def init
        super
        self.img = 'products/odl.png'
      end
    end
  end
end
