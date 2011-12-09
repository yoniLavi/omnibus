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

solr_dir = node['chef_server']['chef-solr']['dir']
solr_etc_dir = File.join(solr_dir, "etc")
solr_jetty_dir = File.join(solr_dir, "jetty")
solr_data_dir = File.join(solr_dir, "data")
solr_home_dir = File.join(solr_dir, "home")

[ solr_dir, solr_etc_dir, solr_jetty_dir, solr_data_dir, solr_home_dir ].each do |dir_name|
  directory dir_name do
    owner node['chef_server']['user']['username']
    mode '0700'
    recursive true
  end
end

solr_config = File.join(solr_etc_dir, "solr.rb")

template File.join(solr_etc_dir, "solr.rb") do
  source "solr.rb.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(node['chef_server']['chef-solr'].to_hash)
end

solr_installed_file = File.join(solr_dir, "installed")

execute "/opt/opscode/bin/chef-solr-installer -c #{solr_config} -f" do
  user node['chef_server']['user']['username'] 
  not_if { File.exists?(solr_installed_file) }
  notifies :create, "file[#{solr_installed_file}]", :immediately
end

file solr_installed_file do
  owner "root"
  group "root"
  mode "0644"
  content "Delete me to force re-install solr - dangerous"
  action :nothing
end

should_notify = OmnibusHelper.should_notify?("chef-solr")

template File.join(solr_jetty_dir, "etc", "jetty.xml") do
  owner node['chef_server']['user']['username']
  mode "0644"
  source "jetty.xml.erb"
  variables(node['chef_server']['chef-solr'].to_hash)
  notifies :restart, 'service[chef-solr]' if should_notify
end

template File.join(solr_home_dir, "conf", "solrconfig.xml") do
  owner node['chef_server']['user']['username']
  mode "0644"
  source "solrconfig.xml.erb"
  variables(node['chef_server']['chef-solr'].to_hash)
  notifies :restart, 'service[chef-solr]' if should_notify
end

runit_service "chef-solr"

