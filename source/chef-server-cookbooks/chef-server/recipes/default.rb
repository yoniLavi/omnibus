#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ENV['PATH'] = "/opt/opscode/bin:/opt/opscode/embedded/bin:#{ENV['PATH']}"

directory "/etc/opscode" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/opscode/chef-server-running.json" do
  owner "root"
  group "root"
  content Chef::JSONCompat.to_json_pretty({ "chef_server" => node['chef_server'].to_hash, "run_list" => node.run_list })
  not_if { File.exists?("/etc/opscode/chef-server-running.json") }
end

# Create the Chef User
include_recipe "chef-server::users"

# Install our runit instance
include_recipe "runit"

# Configure Services
[ "couchdb", "rabbitmq", "chef-solr", "chef-expander", "chef-server-api", "chef-server-webui", "nginx" ].each do |service|
  if node["chef_server"][service]["enable"]
    include_recipe "chef-server::#{service}"
  else
    include_recipe "chef-server::#{service}_disable"
  end
end
