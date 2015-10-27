module JellyfishOdl
  module Provider
    class Odl < ::Provider
      def network_topology
        odl_firewall = odl_client odl_service
        "[#{odl_firewall.rules.to_json}]"
        # '[{"vyatta-security-firewall:name":[{"tagnode":"test","rule":[{"tagnode":1,"action":"accept"},{"tagnode":2,"action":"drop"}]}]}]'
      end

      def add_rule
        '[{"vyatta-security-firewall:name":[{"tagnode":"test","rule":[{"tagnode":1,"action":"accept"},{"tagnode":2,"action":"drop"}]}]}]'
      end

      def edit_rule(rule)
        '[{"vyatta-security-firewall:name":[{"tagnode":"test","rule":[{"tagnode":1,"action":"accept"},{"tagnode":2,"action":"drop"}]}]}]'
      end

      def remove_rule
        '[{"vyatta-security-firewall:name":[{"tagnode":"test","rule":[{"tagnode":1,"action":"accept"},{"tagnode":2,"action":"drop"}]}]}]'
      end

      def odl_client(odl_service)
        odl_client_class = Class.new do
          attr_accessor :odl_service
          attr_accessor :default_client_ip, :default_action
          attr_accessor :odl_controller_ip, :odl_controller_port, :odl_username, :odl_password
          def initialize(odl_service)
            @odl_service = odl_service
            @odl_controller_ip = @odl_service.provider.answers.where(name: 'ip_address').last.value
            @odl_controller_port = @odl_service.provider.answers.where(name: 'port').last.value
            @odl_username = @odl_service.provider.answers.where(name: 'username').last.value
            @odl_password = @odl_service.provider.answers.where(name: 'password').last.value
            # GET ODL CLIENT IP - STORED ON PRODUCT
            @default_client_ip = @odl_service.product.answers.where(name: 'product_placeholder').last.value
            # GET ODL DEFAULT RULE ACTION - STORED ON ORDER
            @default_action = @odl_service.answers.where(name: 'order_placeholder').last.value
          end
          def headers
            { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
          end
          def auth
            { username: @odl_username, password: @odl_password }
          end
          def rules_endpoint
            "http://#{@odl_controller_ip}:#{@odl_controller_port}/restconf/config/network-topology:network-topology/topology/topology-netconf/node/vRouter5600/yang-ext:mount/vyatta-security:security/vyatta-security-firewall:firewall/name/test"
          end
          def rule_endpoint(rule_num)
            rules_endpoint+"/rule/#{rule_num}"
          end
          def rules
            HTTParty.get(rules_endpoint, basic_auth: auth, headers: headers)
          end
          def next_rule_num
            current_max_tagnode = rules.first.second[0]['rule'].max_by { |i| i['tagnode'] }['tagnode'] + 1
            rule_buffer_threshold = 5.0
            next_num = Integer((current_max_tagnode/rule_buffer_threshold).ceil*rule_buffer_threshold)
            [Integer(rule_buffer_threshold), next_num].max
          end
          def create_auto_rule(remote_ip=@default_client_ip)
            create_rule(next_rule_num, @default_action, @default_client_ip, remote_ip)
          end
          def update_rule(rule)
            '[]'
          end
          def create_rule(rule_num=0, action, source_ip, dest_ip)
            body = { rule: { tagnode: rule_num, action: action, source: {address: source_ip}, destination: {address: dest_ip} } }.to_json
            HTTParty.post(rules_endpoint, basic_auth: auth, headers: headers, body: body) unless rule_num < 1
          end
          def delete_rule(rule_num=0)
            HTTParty.delete(rule_endpoint(rule_num), basic_auth: auth, headers: headers) unless rule_num < 1
          end
        end
        @odl_client ||= odl_client_class.new odl_service
      end

      private

      def odl_service
        @odl_service ||= JellyfishOdl::Service::Server.last
      end

      def client
        @client ||= HTTParty
      end
    end
  end
end
