#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: omnibus
# Recipe:: release
#
# Copyright 2011, Opscode, Inc.
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

include_recipe 'omnibus::package'

Chef::Resource::RubyBlock.send(:include, Omnibus::Helper)

gem_package 'fog'

asset_name = node.run_state[:asset_name]
asset_path = node.run_state[:asset_path]
#s3_file_key = "#{node[:platform]}-#{node[:kernel][:machine]}/#{asset_name}"
s3_file_key = "#{node[:platform]}/#{asset_name}"

begin
  access_key = node['aws']['access_key']
  secret_access_key = node['aws']['secret_access_key']
  raise unless access_key && secret_access_key
rescue
  raise Chef::Exceptions::AttributeNotFound, "Cannot release package node['aws']['access_key'] or node['aws']['secret_access_key'] not set properly.  See README for usage info."
end

ruby_block 'push packages to s3' do
  block do
    put_in_bucket(asset_path, node['omnibus']['chef-client']['bucket_name'], s3_file_key, access_key, secret_access_key)
  end
end
