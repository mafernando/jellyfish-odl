module JellyfishOdl
  module Provider
    class Odl < ::Provider
      def network_topology
        "[#{odl_firewall.rules.to_json}]"
      end

      def shift_drop_rule
        odl_firewall.shift_drop_rule
        network_topology
      end

      def add_rule
        network_topology
      end

      def edit_rule(rule)
        "[#{odl_firewall.update_rule(rule).to_json}]"
      end

      def remove_rule(rule_num)
        "[#{odl_firewall.delete_rule(rule_num).to_json}]"
      end

      def odl_client(odl_service)
        odl_client_class = Class.new do
          attr_accessor :odl_service
          attr_accessor :default_rule_source, :default_action, :default_rule_protocol, :default_rule_port
          attr_accessor :odl_controller_ip, :odl_controller_port, :odl_username, :odl_password
          def initialize(odl_service)
            @odl_service = odl_service
            @odl_controller_ip = @odl_service.provider.answers.where(name: 'ip_address').last.value
            @odl_controller_port = @odl_service.provider.answers.where(name: 'port').last.value
            @odl_username = @odl_service.provider.answers.where(name: 'username').last.value
            @odl_password = @odl_service.provider.answers.where(name: 'password').last.value
            @default_rule_source = @odl_service.answers.where(name: 'default_rule_source').last.value
            @default_action = 'accept'
            persist_last_drop_rule
          end
          def last_drop_rule_tagnode
            # GET LAST DROP RULE TAGNODE - DEFAULTS TO 0, WILL ERROR B/C NO RULE CAN BE HAVE 0 TAGNODE
            last_drop_rule_tagnode = 0
            begin
              rule_set = rules['vyatta-security-firewall:name'].first['rule']
              # FIND ALL DROP RULES THAT CONTAIN NO OTHER ATTRIBUTES AND GET THE MAX TAGNODE (RULE ID)
              last_drop_rule_tagnode = rule_set.find_all { |i| i['source'] == nil && i['destination'] == nil && i['action'] == 'drop'}.max_by { |j| j['tagnode'] }['tagnode']
            rescue
            end
            last_drop_rule_tagnode
          end
          def persist_last_drop_rule
            # STORE DROP RULE AS ANSWER EACH TIME THIS CLIENT IS CREATED - SHOULD NOT CREATE DUPLICATES
            drop_rule_answer_name = 'last_drop_rule_tagnode'
            drop_rule_answers = @odl_service.answers.where(name: drop_rule_answer_name)
            drop_rule_answer = drop_rule_answers.empty? ? @odl_service.answers.new : drop_rule_answers.last
            drop_rule_answer.name = drop_rule_answer_name
            drop_rule_answer.value = last_drop_rule_tagnode
            drop_rule_answer.value_type = ValueTypes::TYPES[:integer]
            drop_rule_answer.save
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
            rule_set = rules.first.second[0]['rule']
            current_max_tagnode = (rule_set == nil) ? 1 : rule_set.max_by { |i| i['tagnode'] }['tagnode'] + 1
            rule_buffer_threshold = 5.0
            Integer((current_max_tagnode/rule_buffer_threshold).ceil*rule_buffer_threshold)
          end
          def update_rule(rule)
            # CLEAN RULE PARTS
            rule_parts = {}
            rule_parts['tagnode'] = "#{rule['tagnode']}" if rule['tagnode']
            rule_parts['source'] = rule['source'] if rule['source']
            rule_parts['destination'] = rule['destination'] if rule['destination']
            rule_parts['action'] = "#{rule['action']}" if rule['action']
            body = { rule: rule_parts }.to_json
            HTTParty.put(rule_endpoint(rule_parts['tagnode']), basic_auth: auth, headers: headers, body: body, timeout: http_party_timeout)
          end
          def create_auto_rule(remote_ip=@default_rule_source)
            # GET TAGNODE FOR NEXT RULE
            tagnode = next_rule_num

            # CRATE RULE FOR NEW WEBSERVER
            create_rule(tagnode, @default_action, @default_rule_source, remote_ip)

            # ADD DROP RULE TO END
            # shift_drop_rule(tagnode+5)
          end
          def shift_drop_rule
            # DELETE THE OLD DROP RULE TAGNODE
            delete_rule last_drop_rule_tagnode

            # CREATE A NEW DROP RULE TAGNODE AT END
            body = { rule: { tagnode: next_rule_num, action: 'drop'} }.to_json
            HTTParty.post(rules_endpoint, basic_auth: auth, headers: headers, body: body, timeout: http_party_timeout)
          end
          def create_rule(rule_num=0, action, source_ip, dest_ip)
            body = { rule: { tagnode: rule_num, action: action, source: {address: source_ip}, destination: {address: dest_ip} } }.to_json
            HTTParty.post(rules_endpoint, basic_auth: auth, headers: headers, body: body, timeout: http_party_timeout) unless rule_num < 1
          end
          def delete_rule(rule_num=0)
            HTTParty.delete(rule_endpoint(rule_num) , basic_auth: auth, headers: headers, timeout: http_party_timeout) unless rule_num.to_i < 1
          end
          def http_party_timeout
            240
          end
          def dummy_data
            # CONVERT THIS TO JSON AND THEN PUT IN AN ARRAY AND THEN SEND BACK TO SIMULATE INDEX BEHAVIOR
            {'vyatta-security-firewall:name'=>[{'tagnode'=>'test','rule'=>[{'tagnode'=>1,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>20,'destination'=>{'address'=>'127.0.0.1'},'action'=>'accept'},{'tagnode'=>16,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>21,'action'=>'drop'}]}]}
          end
        end
        @odl_client ||= odl_client_class.new odl_service
      end

      private

      def odl_firewall
        @odl_firewall = odl_client odl_service
      end

      def odl_service
        @odl_service ||= JellyfishOdl::Service::Router.last
      end

      def client
        @client ||= HTTParty
      end
    end
  end
end
