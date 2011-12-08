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

chef_server_api_dir = node['chef_server']['chef-server-api']['dir']
chef_server_api_etc_dir = File.join(chef_server_api_dir, "etc")
chef_server_api_cache_dir = File.join(chef_server_api_dir, "cache")
chef_server_api_sandbox_dir = File.join(chef_server_api_dir, "sandbox")
chef_server_api_checksum_dir = File.join(chef_server_api_dir, "checksum")
chef_server_api_cookbook_tarball_dir = File.join(chef_server_api_dir, "cookbook-tarballs")
chef_server_api_working_dir = File.join(chef_server_api_dir, "working")

[ 
  chef_server_api_dir,
  chef_server_api_etc_dir,
  chef_server_api_cache_dir,
  chef_server_api_sandbox_dir,
  chef_server_api_checksum_dir,
  chef_server_api_cookbook_tarball_dir,
  chef_server_api_working_dir
].each do |dir_name|
  directory dir_name do
    owner node['chef_server']['user']['username']
    mode '0700'
    recursive true
  end
end

chef_server_api_config = File.join(chef_server_api_etc_dir, "server.rb")

template chef_server_api_config do
  source "server.rb.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(node['chef_server']['chef-server-api'].to_hash)
  notifies :restart, 'service[chef-server-api]'
end

template "/opt/opscode/embedded/lib/ruby/gems/1.9.1/gems/chef-server-api-#{Chef::VERSION}/config.ru" do
  source "chef-server-api.ru.erb" 
  mode "0644"
  owner "root"
  group "root"
  notifies :restart, 'service[chef-server-api]'
end

unicorn_config File.join(chef_server_api_etc_dir, "unicorn.rb") do
  listen node['chef_server']['chef-server-api']['listen'] => { 
    :backlog => node['chef_server']['chef-server-api']['backlog'],
    :tcp_nodelay => node['chef_server']['chef-server-api']['tcp_nodelay']
  }
  worker_timeout node['chef_server']['chef-server-api']['worker_timeout']
  working_directory chef_server_api_working_dir 
  worker_processes node['chef_server']['chef-server-api']['worker_processes']  
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, 'service[chef-server-api]'
end

runit_service "chef-server-api"

template "/etc/chef/client.rb" do
  owner "root"
  group "root"
  mode "0644"
  source "client.rb.erb"
  not_if { File.exists?("/etc/chef/client.rb") }
end

template "/etc/chef/knife.rb" do
  owner "root"
  group "root"
  mode "0644"
  source "knife.rb.erb"
  not_if { File.exists?("/etc/chef/knife.rb") }
end

