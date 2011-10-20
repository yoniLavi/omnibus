#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: omnibus
# Recipe:: build
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

source_dir = "#{node['omnibus']['home']}\\source"
embedded_dir = "#{node['chef-full']['home']}\\embedded"

case node['platform']
when 'windows'

  # ensure cache directory exists
  directory Chef::Config[:file_cache_path] do
    mode "0755"
    action :nothing
  end.run_action(:create)

  directory node['omnibus']['home'] do
    mode "0755"
    action :create
  end

  %w{ source pkg }.each do |dir|
    directory "#{node['omnibus']['home']}/#{dir}" do
      mode "0755"
      action :create
    end
  end

  directory node['chef-full']['home'] do
    recursive true
    mode "0755"
    action :create
  end

  %w{ bin embedded }.each do |dir|
    directory "#{node['chef-full']['home']}/#{dir}" do
      mode "0755"
      action :create
    end
  end

  include_recipe '7-zip'

  # Ruby 1.9
  ruby_file_name = ::File.basename(node['chef-full']['ruby']['url'])
  remote_file "#{node['omnibus']['home']}/source/#{ruby_file_name}" do
    source node['chef-full']['ruby']['url']
    checksum node['chef-full']['ruby']['checksum']
    notifies :run, "windows_batch[unzip_and_move_ruby]", :immediately
  end
  unzip_dir_name =  "#{source_dir}\\" << File.basename(ruby_file_name, ".7z")
  windows_batch "unzip_and_move_ruby" do
    code <<-EOH
    "#{node['7-zip']['home']}\\7z.exe" x #{source_dir}\\#{ruby_file_name} -o#{source_dir} -r -y
    xcopy #{unzip_dir_name} \"#{embedded_dir}\" /e /y
    EOH
    action :nothing
  end

  # Ruby DevKit
  devkit_file_name = ::File.basename(node['chef-full']['ruby_dev_kit']['url'])
  template "#{embedded_dir}/config.yml" do
    source "config.yml.erb"
    variables(:ruby_path => "#{embedded_dir}")
  end
  remote_file "#{source_dir}/#{devkit_file_name}" do
    source node['chef-full']['ruby_dev_kit']['url']
    checksum node['chef-full']['ruby_dev_kit']['checksum']
    notifies :run, "windows_batch[install_devkit_and_enhance_ruby]", :immediately
    not_if { ::File.exists?("#{embedded_dir}/dk.rb") }
  end
  windows_batch 'install_devkit_and_enhance_ruby' do
    code <<-EOH
    #{source_dir}\\#{devkit_file_name} -y -o\"#{embedded_dir}\"
    cd \"#{embedded_dir}\" & \"#{embedded_dir}\\bin\\ruby.exe\" \"#{embedded_dir}\\dk.rb\" install
    EOH
    action :nothing
  end

else

  # *nix stuff here

end
