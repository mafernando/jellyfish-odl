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
    end
  end
end
