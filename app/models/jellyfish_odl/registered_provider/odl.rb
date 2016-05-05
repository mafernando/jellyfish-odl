module JellyfishOdl
  module RegisteredProvider
    class Odl < ::RegisteredProvider
      def self.load_registered_providers
        return unless super

        transaction do
          [
            set('ODL', '49d56e49-8ddc-486b-aadc-a821bfc8b451')
          ].each { |s| create! s.merge!(type: 'JellyfishOdl::RegisteredProvider::Odl') }
        end
      end

      def provider_class
        'JellyfishOdl::Provider::Odl'.constantize
      end

      def description
        'OpenDaylight Services'
      end

      def tags
        ['odl']
      end

      def questions
        [
          { name: :odl_version, value_type: :string, field: :odl_versions, required: true },
          { name: :ip_address, value_type: :string, field: :text, label: 'Controller IP Address', required: true },
          { name: :port, value_type: :string, field: :text, label: 'Controller Port', required: true },
          { name: :username, value_type: :string, field: :text, label: 'ODL Username', required: true },
          { name: :password, value_type: :password, field: :password, label: 'ODL Password', required: :true }
        ]
      end
    end
  end
end
