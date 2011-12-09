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

couchdb_dir = node['chef_server']['couchdb']['dir']
couchdb_etc_dir =  File.join(node['chef_server']['couchdb']['dir'], "etc")
couchdb_data_dir = File.join(node['chef_server']['couchdb']['dir'], "data")
couchdb_log_dir = File.join(node['chef_server']['couchdb']['dir'], "log")

# Create the CouchDB directories
[ couchdb_dir, couchdb_etc_dir, couchdb_data_dir, couchdb_log_dir ].each do |dir_name|
  directory dir_name do
    mode "0700"
    recursive true
    owner node['chef_server']['user']['username']
  end
end

# Drop off the CouchDB configuration file
template File.join(couchdb_etc_dir, "local.ini") do
  source "local.ini.erb"
  owner node['chef_server']['user']['username'] 
  mode "0600"
  variables(node['chef_server']['couchdb'].to_hash)
  notifies :restart, "service[couchdb]" if OmnibusHelper.should_notify?("couchdb")
end

# Start and enable the service
runit_service "couchdb" 
