module JellyfishOdl
  module ProductType
    class RouterV3 < ::ProductType
      def self.load_product_types
        return unless super

        transaction do
          [
            set('ODL Connected Router V3', 'f91a00c9-e315-4dd6-a38c-d158866fb1b3', provider_type: 'JellyfishOdl::Provider::Odl')
          ].each do |s|
            create! s.merge!(type: 'JellyfishOdl::ProductType::RouterV3')
          end
        end
      end

      def description
        'ODL Connected Router V3'
      end

      def tags
        ['router']
      end

      def product_questions
        [
          { name: :policy_name, value_type: :string, field: :text, label: 'Policy Name', required: true },
          { name: :policy_dest_address, value_type: :string, field: :text, label: 'Policy Destination Address', required: false },
          { name: :policy_src_address, value_type: :string, field: :text, label: 'Policy Source Address', required: false }
        ]
      end

      def product_class
        'JellyfishOdl::Product::RouterV3'.constantize
      end
    end
  end
end
