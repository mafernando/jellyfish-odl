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
        ]
      end

      def order_questions
        [
          { name: :default_rule_client_ip, value_type: :string, field: :text, label: 'Default Rule Client IP', required: false },
          { name: :default_rule_action, value_type: :string, field: :text, label: 'Default Rule Action', required: false }
        ]
      end

      def service_class
        'JellyfishOdl::Service::Server'.constantize
      end
    end
  end
end
