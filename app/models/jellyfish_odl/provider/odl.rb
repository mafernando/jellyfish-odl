module JellyfishOdl
  module Provider
    class Odl < ::Provider
      def network_topology
        auth = {:username => settings[:username], :password => settings[:password]}

        base_url = "http://#{settings[:ip_address]}:#{settings[:port]}"

        headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}

        odl_module = 'restconf/operational/opendaylight-inventory:nodes/'

        composite_url = "#{base_url}/#{odl_module}"

        response = client.get(composite_url, :basic_auth => auth, :headers => headers)

        nodes = []

        begin
          response['nodes']['node'].each { |x|
            node = {}

            i = 0
            node_connector = []
            x['node-connector'].each { |y|
              node_connector << { :id => y['id'] }
            }

            node[:node_connector] = node_connector

            nodes << { x['id'] => node }
          }
        rescue
          p 'Could not parse output'
        end

        nodes
      end

      private

      def client
        @client ||= HTTParty
      end
    end
  end
end
