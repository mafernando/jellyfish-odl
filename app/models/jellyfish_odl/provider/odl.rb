module JellyfishOdl
  module Provider
    class Odl < ::Provider
      def network_topology
        "[#{odl_firewall.rules.to_json}]"
      end

      def enable_video_policy
        toggle_policy('accept')
      end

      def disable_video_policy
        toggle_policy('drop')
      end

      def toggle_policy(new_action)
        if (new_action == 'accept') || (new_action == 'drop')
          "[#{odl_firewall.toggle_policy(new_action).to_json}]"
        else
          '[]'
        end
      end

      def shift_drop_rule
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
        # modify endpoints based on odl version
        odl_client_class = Class.new do
          attr_accessor :odl_service, :odl_version, :router_version, :router_name
          attr_accessor :default_rule_source, :policy_dest_address, :policy_src_address
          attr_accessor :default_action, :default_rule_protocol, :default_rule_port
          attr_accessor :odl_controller_ip, :odl_controller_port, :odl_username, :odl_password
          def initialize(odl_service)
            @odl_service = odl_service
            @odl_version = @odl_service.provider.answers.where(name: 'odl_version').last.value
            @odl_controller_ip = @odl_service.provider.answers.where(name: 'ip_address').last.value
            @odl_controller_port = @odl_service.provider.answers.where(name: 'port').last.value
            @odl_username = @odl_service.provider.answers.where(name: 'username').last.value
            @odl_password = @odl_service.provider.answers.where(name: 'password').last.value
            @router_version = @odl_service.answers.where(name: 'router_version').last.value
            @router_name = @odl_service.answers.where(name: 'router_name').last.value
            @policy_dest_address = @odl_service.answers.where(name: 'policy_dest_address').last.value
            @policy_src_address = @odl_service.answers.where(name: 'policy_src_address').last.value
            @default_rule_source = @policy_src_address
            @default_action = 'accept'
          end
          def toggle_policy(toggle_action='drop')
            # check if policy already exists on a rule
            rule_set = []
            @last_policy_rule_tagnode = 0
            begin
              # get the latest rules
              rule_set = rules['vyatta-security-firewall:name'].first['rule']
              # find and save the last rule that matches the policy source and destination address
              @last_policy_rule_tagnode = Integer(rule_set.find_all { |i|
                (!i['source'].nil?) && (!i['source']['address'].nil?) && (i['source']['address'] == @policy_src_address) &&
                  (!i['destination'].nil?) && (!i['destination']['address'].nil?) && (i['destination']['address'] == @policy_dest_address)}.max_by { |j| j['tagnode'] }['tagnode'])
            rescue
            end
            if @last_policy_rule_tagnode > 0
              # policy tagnode exists so delete and recreate it - get rule if we've seen it in the rule set
              rule = rule_set.find_all { |i| i['tagnode'] == @last_policy_rule_tagnode }.last
              # delete & create instead of update to speed up transactions on odl
              if !rule.nil? && rule['action'] != toggle_action
                delete_rule(@last_policy_rule_tagnode)
                # we should never create a drop rule
                create_rule(@last_policy_rule_tagnode, toggle_action, @policy_src_address, @policy_dest_address) if toggle_action == 'accept'
              end
            else
              # policy tagnode does not exist so create it
              # we should never create a drop rule
              create_rule(next_rule_num, toggle_action, @policy_src_address, @policy_dest_address) if toggle_action == 'accept'
            end
            # finally return latest firewall policy
            rules
          end
          def headers
            { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
          end
          def auth
            { username: @odl_username, password: @odl_password }
          end
          def rules_endpoint
            "http://#{@odl_controller_ip}:#{@odl_controller_port}/restconf/config/network-topology:network-topology/topology/topology-netconf/node/#{@router_name}/yang-ext:mount/vyatta-security:security/vyatta-security-firewall:firewall/name/test"
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
            # setup up the rule parts for http call
            rule_parts = {}
            rule_parts['tagnode'] = "#{rule['tagnode']}" if rule['tagnode']
            rule_parts['source'] = {'address'=>rule['source']} if rule['source']
            rule_parts['destination'] = {'address'=>rule['destination']} if rule['destination']
            rule_parts['action'] = "#{rule['action']}" if rule['action']
            body = { rule: rule_parts }.to_json
            HTTParty.put(rule_endpoint(rule_parts['tagnode']), basic_auth: auth, headers: headers, body: body, timeout: http_party_timeout)
          end
          def create_auto_rule(remote_ip=@default_rule_source)
            # get tagnode for next rule
            tagnode = next_rule_num
            # create rule for new webserver
            create_rule(tagnode, @default_action, @default_rule_source, remote_ip)
          end
          def create_rule(rule_num=0, action, source_ip, dest_ip)
            body = { rule: { tagnode: rule_num, action: action, source: {address: source_ip}, destination: {address: dest_ip} } }.to_json
            HTTParty.post(rules_endpoint, basic_auth: auth, headers: headers, body: body, timeout: http_party_timeout) unless rule_num < 1
          end
          def delete_rule(rule_num=0)
            HTTParty.delete(rule_endpoint(rule_num) , basic_auth: auth, headers: headers) unless rule_num.to_i < 1
          end
          def http_party_timeout
            5
          end
          def dummy_data
            # convert this to JSON and then put it in an array and return it to simulate index behavior
            {'vyatta-security-firewall:name'=>[{'tagnode'=>'test','rule'=>[{'tagnode'=>1,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>20,'destination'=>{'address'=>'127.0.0.1'},'action'=>'accept'},{'tagnode'=>16,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>21,'action'=>'drop'}]}]}
          end
        end
        @odl_client ||= odl_client_class.new odl_service
      end

      # private

      def odl_firewall
        # odl_version = self.answers.where(name: 'odl_version').last.value
        @odl_firewall = odl_client odl_service
      end

      def odl_service
        # returns last service assoc. with the given provider
        @odl_service ||= ::Service.where(product: ::Product.where(provider: self)).last
      end

      def client
        @client ||= HTTParty
      end
    end
  end
end
