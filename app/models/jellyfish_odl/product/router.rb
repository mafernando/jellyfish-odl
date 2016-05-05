module JellyfishOdl
  module Product
    class Router < ::Product
      def order_questions
        [
        ]
      end

      def service_class
        'JellyfishOdl::Service::Router'.constantize
      end

      private

      def init
        super
        self.img = 'products/odl.png'
      end
    end
  end
end
