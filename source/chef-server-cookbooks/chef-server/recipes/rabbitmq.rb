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

rabbitmq_dir = node['chef_server']['rabbitmq']['dir']
rabbitmq_etc_dir = File.join(rabbitmq_dir, "etc")
rabbitmq_mnesia_dir = File.join(rabbitmq_dir, "db")
rabbitmq_log_dir = File.join(rabbitmq_dir, "log")

[ rabbitmq_dir, rabbitmq_etc_dir, rabbitmq_mnesia_dir, rabbitmq_log_dir ].each do |dir_name|
  directory dir_name do
    owner node['chef_server']['user']['username']
    mode '0700'
    recursive true
  end
end

config_file = File.join(node['chef_server']['rabbitmq']['dir'], "etc", "rabbitmq.conf") 

template "/opt/opscode/embedded/lib/erlang/lib/rabbitmq_server-2.2.0/sbin/rabbitmq-env" do
  owner "root"
  group "root"
  mode "0755"
  variables( :config_file => config_file )
  source "rabbitmq-env.erb"
end

template config_file do
  source "rabbitmq.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(node['chef_server']['rabbitmq'].to_hash)
end

runit_service "rabbitmq"

ruby_block "sleep for rabbit" do
  block do
    Chef::Log.debug("Sleeping for rabbitmq to start up the first time")
    sleep 5
  end
end

# add a chef vhost to the queue
execute "/opt/opscode/embedded/bin/rabbitmqctl add_vhost #{node['chef_server']['rabbitmq']['vhost']}" do
  not_if "/opt/opscode/embedded/bin/rabbitmqctl list_vhosts| grep #{node['chef_server']['rabbitmq']['vhost']}"
end

# create chef user for the queue
execute "/opt/opscode/embedded/bin/rabbitmqctl add_user #{node['chef_server']['rabbitmq']['user']} #{node['chef_server']['rabbitmq']['password']}" do
  not_if "/opt/opscode/embedded/bin/rabbitmqctl list_users |grep #{node['chef_server']['rabbitmq']['user']}"
end

# grant the mapper user the ability to do anything with the /chef vhost
# the three regex's map to config, write, read permissions respectively
execute "/opt/opscode/embedded/bin/rabbitmqctl set_permissions -p #{node['chef_server']['rabbitmq']['vhost']} #{node['chef_server']['rabbitmq']['user']} \".*\" \".*\" \".*\"" do
  not_if "/opt/opscode/embedded/bin/rabbitmqctl list_user_permissions #{node['chef_server']['rabbitmq']['user']}|grep #{node['chef_server']['rabbitmq']['vhost']}"
end

