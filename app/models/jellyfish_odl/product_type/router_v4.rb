module JellyfishOdl
  module ProductType
    class RouterV4 < ::ProductType
      def self.load_product_types
        return unless super

        transaction do
          [
            set('ODL Connected Router V4', '36a68bc9-900e-4371-b770-b5bb096249a8', provider_type: 'JellyfishOdl::Provider::Odl')
          ].each do |s|
            create! s.merge!(type: 'JellyfishOdl::ProductType::RouterV4')
          end
        end
      end

      def description
        'ODL Connected Router V4'
      end

      def tags
        ['router']
      end

      def product_questions
        [
          { name: :router_name, value_type: :string, field: :text, label: 'Router Name', required: true },
          { name: :policy_name, value_type: :string, field: :text, label: 'Policy Name', required: true },
          { name: :policy_dest_address, value_type: :string, field: :text, label: 'Policy Destination Address', required: false },
          { name: :policy_src_address, value_type: :string, field: :text, label: 'Policy Source Address', required: false }
        ]
      end

      def product_class
        'JellyfishOdl::Product::RouterV4'.constantize
      end
    end
  end
end
