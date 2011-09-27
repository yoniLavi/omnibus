#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: omnibus
# Library:: helper
#
# Copyright:: 2011, Opscode, Inc.
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

require 'rubygems'
require 'rubygems/format'

module Omnibus
  module Helper

    def gem_executables(gem_name, gem_version=nil, gem_executable = nil)
      unless gem_version
        @gem_env = Chef::Provider::Package::Rubygems::CurrentGemEnvironment.new
        dependency = Gem::Dependency.new(gem_name, '>= 0')
        gem_version = @gem_env.candidate_version_from_remote(dependency, *[]).to_s
      end
      puts gem_version
      # extract a Gem's executable names from the remote .gem file since
      # you *CANNOT* retrieve these executables using Gem::DependencyInstaller >_<
      gem_file = "#{gem_name}-#{gem_version}.gem"
      gem_file_cached_path = "#{Chef::Config[:file_cache_path]}/#{gem_file}"
      r = Chef::Resource::RemoteFile.new(gem_file_cached_path, run_context)
      r.source("http://rubygems.org/gems/#{gem_file}")
      r.run_action(:create)
      Gem::Format.from_file_by_path(gem_file_cached_path).spec.executables || []
    end

    def put_in_bucket(filename, bucket_name, file_key, access_key, secret_access_key)
      require 'rubygems'
      Gem.clear_paths
      require 'fog'

      connection = ::Fog::Storage.new(
        :provider => 'AWS',
        :aws_access_key_id => access_key,
        :aws_secret_access_key => secret_access_key
      )

      directory = connection.directories.create(
        :key    => bucket_name,
        :public => true
      )

      directory.files.create(
        :key    => file_key,
        :body   => ::File.open(filename, 'rb'){|io| io.read},
        :public => true
      )
    end
  end
end

Chef::Recipe.send(:include, Omnibus::Helper)
