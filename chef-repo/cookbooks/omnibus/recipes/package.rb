#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: omnibus
# Recipe:: package
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

include_recipe 'omnibus::build'
include_recipe 'wix'

case node['platform']
when 'windows'
  pkg_dir = "#{node['omnibus']['home']}\\pkg"
  #asset_name = "chef-full-#{node['chef-full']['version']}-#{node['chef-full']['iteration']}-#{node['kernel']['machine']}.msi"
  asset_name = "chef-full-#{node['chef-full']['version']}-#{node['chef-full']['iteration']}.msi"
  asset_path = "#{pkg_dir}\\#{asset_name}"

  version = node['chef-full']['version'].split('.')

  # package localization template
  template "#{pkg_dir}/ChefFull-en-us.wxl" do
    source "ChefFull-en-us.wxl.erb"
    mode "0755"
  end

  # UI assets
  remote_directory "#{pkg_dir}/assets" do
    source "assets"
    mode "0755"
  end

  # package global config
  template "#{pkg_dir}/ChefFull-Config.wxi" do
    source "ChefFull-Config.wxi.erb"
    mode "0755"
    variables(
      :product_name => "Chef Full-Stack Installer",
      :guid => node['chef-full']['package_guid'],
      :major_version => version[1],
      :minor_version => version[2],
      :build_version => node['chef-full']['iteration']
    )
  end

  # package main WXS
  template "#{pkg_dir}/ChefFull.wxs" do
    source "ChefFull.wxs.erb"
    mode "0755"
    variables(
      :global_config => "#{pkg_dir}\\ChefFull-Config.wxi",
      :files_component_group => "ChefFullDir",
      :assets_dir => "#{pkg_dir}\\assets"
    )
  end

  # harvest with heat.exe
  # recursively generate fragment for node['chef-full']['home']
  windows_batch 'harvest package' do
    code <<-EOH
#{node['wix']['home']}\\heat.exe ^
dir \"#{node['chef-full']['home']}\" ^
-nologo -srd -gg ^
-cg ChefFullDir ^
-dr CHEFLOCATION ^
-var var.ChefFullSourceDir ^
-out #{pkg_dir}\\ChefFull-Files.wxs
    EOH
  end

  # compile with candle.exe
  windows_batch 'compile package' do
    code <<-EOH
#{node['wix']['home']}\\candle.exe ^
-nologo ^
-I#{pkg_dir} ^
-dChefFullSourceDir=\"#{node['chef-full']['home']}\" ^
-out #{pkg_dir}\\ ^
#{pkg_dir}\\ChefFull-Files.wxs ^
#{pkg_dir}\\ChefFull.wxs
    EOH
  end

  # link with light.exe
  # LET'S LIGHT THIS CANDLE YO!
  windows_batch 'link package' do
    code <<-EOH
#{node['wix']['home']}\\light.exe ^
-nologo ^
-ext WixUIExtension ^
-cultures:en-us -loc #{pkg_dir}\\ChefFull-en-us.wxl ^
-out #{asset_path} ^
#{pkg_dir}\\ChefFull-Files.wixobj ^
#{pkg_dir}\\ChefFull.wixobj
    EOH
    returns [0,204]
  end

  log "Created MSI package for Chef-Full on #{node[:platform]} #{node[:platform_version]} #{node[:kernel][:machine]}"

else

  # *nix stuff here

end

# save asset_name and asset_path in
# node.run_state for 'omnibus::release'
node.run_state[:asset_name] = asset_name
node.run_state[:asset_path] = asset_path
