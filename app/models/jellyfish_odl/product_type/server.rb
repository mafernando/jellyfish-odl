module JellyfishOdl
  module ProductType
    class Server < ::ProductType
      def self.load_product_types
        return unless super

        transaction do
          [
            set('ODL Server Instance', '91e113c7-865e-4640-ae43-9586c50807e7', provider_type: 'JellyfishOdl::Provider::Odl')
          ].each do |s|
            create! s.merge!(type: 'JellyfishOdl::ProductType::Server')
          end
        end
      end

      def description
        'ODL Server Instance'
      end

      def tags
        ['server']
      end

      def product_questions
        [
          { name: :product_placeholder, value_type: :string, field: :text, label: 'Product Question Placeholder', required: false }
        ]
      end

      def order_questions
        [
          { name: :order_placeholder, value_type: :string, field: :text, label: 'Order Question Placeholder', required: false }
        ]
      end

      def service_class
        'JellyfishOdl::Service::Server'.constantize
      end
    end
  end
end
