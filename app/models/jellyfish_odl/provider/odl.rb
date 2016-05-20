module JellyfishOdl
  module Provider
    class Odl < ::Provider
      def network_topology
        "[#{odl_firewall.rules.to_json}]"
        # "[#{odl_firewall.dummy_data.to_json}]"
      end

      def get_all_firewall_rules
        "[#{odl_firewall.all_rules.to_json}]"
        # "[#{odl_firewall.dummy_data_all.to_json}]"
      end

      def apply_policy
        toggle_policy('apply')
      end

      def remove_policy
        toggle_policy('remove')
      end

      def toggle_policy(new_action)
        if (new_action == 'apply') || (new_action == 'remove')
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

      def remove_rule(rule_num, policy)
        "[#{odl_firewall.delete_rule(rule_num, policy).to_json}]"
      end

      def odl_client(odl_service)
        # modify endpoints based on odl version
        odl_client_class = Class.new do
          attr_accessor :odl_service, :odl_version, :router_name
          attr_accessor :policy_name, :policy_dest_address, :policy_src_address, :policy_action
          attr_accessor :odl_controller_ip, :odl_controller_port, :odl_username, :odl_password
          def initialize(odl_service)
            @odl_service = odl_service
            @odl_version = @odl_service.provider.answers.where(name: 'odl_version').last.value
            @odl_controller_ip = @odl_service.provider.answers.where(name: 'ip_address').last.value
            @odl_controller_port = @odl_service.provider.answers.where(name: 'port').last.value
            @odl_username = @odl_service.provider.answers.where(name: 'username').last.value
            @odl_password = @odl_service.provider.answers.where(name: 'password').last.value
            @router_name = @odl_service.name
            @policy_name = @odl_service.answers.where(name: 'policy_name').last.value
            @policy_dest_address = @odl_service.answers.where(name: 'policy_dest_address').last.value
            @policy_src_address = @odl_service.answers.where(name: 'policy_src_address').last.value
            @policy_action = @odl_service.answers.where(name: 'policy_action').last.value
          end
          def toggle_policy(toggle_action='remove')
            # identify the policy rule to toggle
            tagnode = 0
            rule_set = []
            begin
              # get the latest rules
              rule_key = 'vyatta-security-firewall:name' if @odl_service.type == 'JellyfishOdl::Service::RouterV3'
              rule_key = 'vyatta-security-firewall-v1:name'  if @odl_service.type == "JellyfishOdl::Service::RouterV4"
              rule_set = rules[rule_key].first['rule']
              # identify the last rule matching policy source and destination address
              tagnode = Integer(rule_set.find_all { |i|
                (!i['source'].nil?) && (!i['source']['address'].nil?) && (i['source']['address'] == @policy_src_address) &&
                  (!i['destination'].nil?) && (!i['destination']['address'].nil?) && (i['destination']['address'] == @policy_dest_address)}.max_by { |j| j['tagnode'] }['tagnode'])
            rescue
            end
            # delete the policy rule if it already exists (update is slow on V3)
            delete_rule(tagnode) if tagnode > 0
            # generate a new tagnode if the policy rule DNE, otherwise use the identified tagnode
            tagnode = next_rule_num if tagnode == 0
            # only create the rule if the toggle action is equal to the policy action
            create_rule(tagnode, @policy_action, @policy_src_address, @policy_dest_address) if toggle_action == 'apply'
            # finally return latest firewall policy
            rules
          end
          def headers
            { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
          end
          def auth
            { username: @odl_username, password: @odl_password }
          end
          def rules_endpoint(policy=@policy_name)
            if @odl_service.type == 'JellyfishOdl::Service::RouterV3'
              "http://#{@odl_controller_ip}:#{@odl_controller_port}/restconf/config/network-topology:network-topology/topology/topology-netconf/node/#{@router_name}/yang-ext:mount/vyatta-security:security/vyatta-security-firewall:firewall/name/#{policy}"
            elsif @odl_service.type == "JellyfishOdl::Service::RouterV4"
              "http://#{@odl_controller_ip}:#{@odl_controller_port}/restconf/config/opendaylight-inventory:nodes/node/#{@router_name}/yang-ext:mount/vyatta-security-v1:security/vyatta-security-firewall-v1:firewall/name/#{policy}"
            else
              ''
            end
          end
          def all_rules_endpoint
            if @odl_service.type == 'JellyfishOdl::Service::RouterV3'
              "http://#{@odl_controller_ip}:#{@odl_controller_port}/restconf/config/network-topology:network-topology/topology/topology-netconf/node/#{@router_name}/yang-ext:mount/vyatta-security:security/vyatta-security-firewall:firewall"
            elsif @odl_service.type == "JellyfishOdl::Service::RouterV4"
              "http://#{@odl_controller_ip}:#{@odl_controller_port}/restconf/config/opendaylight-inventory:nodes/node/#{@router_name}/yang-ext:mount/vyatta-security-v1:security/vyatta-security-firewall-v1:firewall"
            else
              ''
            end
          end
          def rule_endpoint(rule_num, policy)
            rules_endpoint(policy)+"/rule/#{rule_num}"
          end
          def rules
            HTTParty.get(rules_endpoint, basic_auth: auth, headers: headers)
          end
          def all_rules
            HTTParty.get(all_rules_endpoint, basic_auth: auth, headers: headers)
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
            rule_parts['tagnode'] = rule['tagnode'] if rule['tagnode']
            rule_parts['source'] = rule['source'] if rule['source']
            rule_parts['destination'] = rule['destination'] if rule['destination']
            rule_parts['action'] = rule['action'] if rule['action']
            body = { rule: rule_parts }.to_json
            HTTParty.put(rule_endpoint(rule_parts['tagnode'], rule['policy']), basic_auth: auth, headers: headers, body: body, timeout: http_party_timeout)
          end
          def create_auto_rule(remote_ip=@policy_src_address)
            # get tagnode for next rule
            tagnode = next_rule_num
            # create rule for new webserver
            create_rule(tagnode, @policy_action, @policy_src_address, remote_ip)
          end
          def create_rule(rule_num=0, action, source_ip, dest_ip)
            begin
              rule_parts = {}
              rule_parts['tagnode'] = rule_num if rule_num
              rule_parts['source'] = {address: source_ip} if source_ip
              rule_parts['destination'] = {address: dest_ip} if dest_ip
              rule_parts['action'] = action if action
              body = { rule: rule_parts }.to_json
              HTTParty.post(rules_endpoint, basic_auth: auth, headers: headers, body: body, timeout: http_party_timeout) unless rule_num < 1
            rescue
            end
          end
          def delete_rule(rule_num=0, policy)
            begin
              HTTParty.delete(rule_endpoint(rule_num, policy) , basic_auth: auth, headers: headers, timeout: http_party_timeout) unless rule_num.to_i < 1
            rescue
            end
          end
          def http_party_timeout
            5
          end
          def dummy_data
            # convert this to JSON and then put it in an array and return it to simulate index behavior
            if @odl_service.type == 'JellyfishOdl::Service::RouterV3'
              {'vyatta-security-firewall:name'=>[{'tagnode'=>'test','rule'=>[{'tagnode'=>1,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>20,'destination'=>{'address'=>'127.0.0.1'},'action'=>'accept'},{'tagnode'=>16,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>21,'action'=>'drop'}]}]}
            elsif @odl_service.type == "JellyfishOdl::Service::RouterV4"
              {'vyatta-security-firewall-v1:name'=>[{'tagnode'=>'test','rule'=>[{'tagnode'=>1,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>20,'destination'=>{'address'=>'127.0.0.1'},'action'=>'accept'},{'tagnode'=>16,'destination'=>{'address'=>'127.0.0.1'},'action'=>'drop'},{'tagnode'=>21,'action'=>'drop'}]}]}
            else
              {}
            end
          end
          def dummy_data_all
            # convert this to JSON and then put it in an array and return it to simulate index behavior
            if @odl_service.type == 'JellyfishOdl::Service::RouterV3'
              {'vyatta-security-firewall:firewall'=>{'name'=>[{'tagnode'=>'test','default-action'=>'drop','rule'=>[{'tagnode'=>5,'destination'=>{'address'=>'127.0.0.8'},'source'=>{'address'=>'127.0.1.9'},'action'=>'accept'},{'tagnode'=>1,'disable'=>[null],'destination'=>{'address'=>'10.128.167.0/24'},'action'=>'accept'},{'tagnode'=>10,'destination'=>{'address'=>'127.0.0.8'},'source'=>{'address'=>'127.0.0.9'},'action'=>'accept'}]}],'global-state-policy'=>{'tcp'=>[],'icmp'=>[],'udp'=>[]}}}
            elsif @odl_service.type == "JellyfishOdl::Service::RouterV4"
              {'vyatta-security-firewall-v1:firewall'=>{'name'=>[{'ruleset-name'=>'video-client','rule'=>[{'tagnode'=>4,'action'=>'accept'}]},{'ruleset-name'=>'test','rule'=>[{'tagnode'=>10,'destination'=>{'address'=>'127.0.0.8'},'action'=>'accept'},{'tagnode'=>15,'source'=>{'address'=>'127.0.0.9'},'destination'=>{'address'=>'127.0.0.6'},'action'=>'accept'}]}]}}
            else
              {}
            end
          end
        end
        @odl_client ||= odl_client_class.new odl_service
      end

      def odl_firewall
        # odl_version = self.answers.where(name: 'odl_version').last.value
        @odl_firewall = odl_client odl_service
      end

      def odl_service
        # returns last service assoc. with the given provider, 1:1 mapping between provider and odl service
        @odl_service ||= ::Service.where(product: ::Product.where(provider: self)).last
      end

      def client
        @client ||= HTTParty
      end
    end
  end
end
