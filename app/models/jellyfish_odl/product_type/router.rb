module JellyfishOdl
  module ProductType
    class Router < ::ProductType
      def self.load_product_types
        return unless super

        transaction do
          [
            set('ODL Connected Router', '5d3a223d-e196-4cdc-8187-2f3d1863787b', provider_type: 'JellyfishOdl::Provider::Odl')
          ].each do |s|
            create! s.merge!(type: 'JellyfishOdl::ProductType::Router')
          end
        end
      end

      def description
        'ODL Connected Router'
      end

      def tags
        ['router']
      end

      def product_questions
        [
          { name: :router_version, value_type: :string, field: :router_versions, required:  true },
          { name: :router_name, value_type: :string, field: :text, label: 'Router Name', required: true },
          { name: :policy_name, value_type: :string, field: :text, label: 'Policy Name', required: true },
          { name: :policy_dest_address, value_type: :string, field: :text, label: 'Policy Destination Address', required: false },
          { name: :policy_src_address, value_type: :string, field: :text, label: 'Policy Source Address', required: false }
        ]
      end

      def product_class
        'JellyfishOdl::Product::Router'.constantize
      end
    end
  end
end
