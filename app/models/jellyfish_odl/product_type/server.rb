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
          { name: :default_rule_source, value_type: :string, field: :text, label: 'Default Rule Source', required: false },
          { name: :default_rule_protocol, value_type: :string, field: :text, label: 'Default Rule Protocol', required: false },
          { name: :default_rule_port, value_type: :string, field: :text, label: 'Default Rule Port', required: false },
        ]
      end

      def service_class
        'JellyfishOdl::Service::Server'.constantize
      end
    end
  end
end
