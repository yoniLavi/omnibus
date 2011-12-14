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
embedded_dir = "#{node['omnibus']['chef-client']['home']}\\embedded"

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

  directory node['omnibus']['chef-client']['home'] do
    recursive true
    mode "0755"
    action :create
  end

  %w{ bin embedded }.each do |dir|
    directory "#{node['omnibus']['chef-client']['home']}/#{dir}" do
      mode "0755"
      action :create
    end
  end

  include_recipe '7-zip'

  # Ruby 1.9
  ruby_file_name = ::File.basename(node['omnibus']['chef-client']['ruby_url'])
  file_cache_path = ::File.expand_path(Chef::Config[:file_cache_path]).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  ruby_download_path = "#{file_cache_path}\\#{ruby_file_name}"
  remote_file ruby_download_path do
    source node['omnibus']['chef-client']['ruby_url']
    checksum node['omnibus']['chef-client']['ruby_checksum']
  end
  unzip_dir_name = "#{file_cache_path}\\" << File.basename(ruby_file_name, ".7z")
  windows_batch "unzip_and_move_ruby" do
    code <<-EOH
    "#{node['7-zip']['home']}\\7z.exe" x #{ruby_download_path} -o#{file_cache_path} -r -y
    xcopy #{unzip_dir_name} \"#{embedded_dir}\" /e /y
    EOH
    action :run
    not_if { ::File.exists?("#{embedded_dir}/bin/ruby.exe") }
  end

  # Ruby DevKit
  devkit_file_name = ::File.basename(node['omnibus']['chef-client']['ruby_dev_kit_url'])
  devkit_download_path = "#{file_cache_path}\\#{devkit_file_name}"
  template "#{embedded_dir}/config.yml" do
    source "config.yml.erb"
    variables(:ruby_path => "#{embedded_dir}")
  end
  remote_file devkit_download_path do
    source node['omnibus']['chef-client']['ruby_dev_kit_url']
    checksum node['omnibus']['chef-client']['ruby_dev_kit_checksum']
  end
  windows_batch 'install_devkit_and_enhance_ruby' do
    code <<-EOH
    #{devkit_download_path} -y -o\"#{embedded_dir}\"
    cd /d \"#{embedded_dir}\" & \"#{embedded_dir}\\bin\\ruby.exe\" \"#{embedded_dir}\\dk.rb\" install
    EOH
    action :run
    not_if { ::File.exists?("#{embedded_dir}/dk.rb") }
  end

else

  # *nix stuff here

end
