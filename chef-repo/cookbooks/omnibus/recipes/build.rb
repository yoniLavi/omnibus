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

include_recipe 'omnibus::prepare'

source_dir = "#{node['omnibus']['home']}\\source"
embedded_dir = "#{node['omnibus']['chef-client']['home']}\\embedded"

case node['platform']
when 'windows'

  # symlink required unix tools
  # we need tar for 'knife cookbook site install' to function correctly
  {"tar.exe" => "bsdtar.exe",
   "libarchive-2.dll" => "libarchive-2.dll",
   "libexpat-1.dll" => "libexpat-1.dll",
   "liblzma-1.dll" => "liblzma-1.dll",
   "libbz2-2.dll" => "libbz2-2.dll",
   "libz-1.dll" => "libz-1.dll"
   }.each do |target, to|
     # TODO we need windows support in the link provider
    execute "mklink #{node['omnibus']['chef-client']['home']}\\bin\\#{target} #{embedded_dir}\\mingw\\bin\\#{to}" do
      not_if{ ::File.exists?("#{node['omnibus']['chef-client']['home']}\\bin\\#{target}") }
    end
  end

  # Chef
  gem_package "chef" do
    version node['omnibus']['chef-client']['version']
    gem_binary "#{embedded_dir}\\bin\\gem"
    options "-n '#{node['omnibus']['chef-client']['home']}\\bin' --no-rdoc --no-ri"
  end

  # gems with precompiled binaries
  %w{ ffi win32-api win32-service }.each do |win_gem|
    gem_package win_gem do
      gem_binary "#{embedded_dir}\\bin\\gem"
      options "-n '#{node['omnibus']['chef-client']['home']}\\bin' --no-rdoc --no-ri --platform=mswin32"
      action :install
    end
  end

  # the rest
  %w{ rdp-ruby-wmi windows-api windows-pr win32-dir win32-event win32-mutex win32-process }.each do |win_gem|
    gem_package win_gem do
      gem_binary "#{embedded_dir}\\bin\\gem"
      options "-n '#{node['omnibus']['chef-client']['home']}\\bin' --no-rdoc --no-ri"
      action :install
    end
  end

  if node['omnibus']['chef-client']['ruby_url'] =~ /ruby-1.8/
    gem_package "win32-open3" do
      gem_binary "#{embedded_dir}\\bin\\gem"
      options "-n '#{node['omnibus']['chef-client']['home']}\\bin' --no-rdoc --no-ri"
      action :install
    end
  end

  # create bin bat files with *relative* paths to ruby.exe
  executables = gem_executables('ohai', '0.6.10')
  executables << gem_executables('chef', node['omnibus']['chef-client']['version'])
  executables.flatten.reject{|g| g =~ /.rb/}.each do |bin|
    template "#{node['omnibus']['chef-client']['home']}\\bin\\#{bin}.bat" do
      source 'relative_path_bin_wrapper.bat.erb'
      mode "0755"
      variables :bin => bin
    end
  end

else

  # *nix stuff here

end
