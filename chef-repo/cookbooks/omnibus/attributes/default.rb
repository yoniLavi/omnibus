#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: omnibus
# Attribute:: default
#
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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

default['chef-full']['version']     = "0.10.4"
default['chef-full']['iteration']   = "1"

default['chef-full']['bucket_name'] = "opscode-full-stack"

case platform
when 'windows'
  default['omnibus']['home']    = "#{ENV['SYSTEMDRIVE']}\\omnibus"
  default['chef-full']['home']  = "#{ENV['SYSTEMDRIVE']}\\opscode\\chef"

  default['chef-full']['package_guid'] = "D607A85C-BDFA-4F08-83ED-2ECB4DCD6BC5"

  default['chef-full']['ruby']['url']       = "http://rubyforge.org/frs/download.php/75128/ruby-1.9.2-p290-i386-mingw32.7z"
  default['chef-full']['ruby']['checksum']  = "58d1cdb08f24f6a1f14ce55f6d14734bf9341c76ab72998072fd98b4e94cf4ed"

  default['chef-full']['ruby_dev_kit']['url']       = "http://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20110712-1620-sfx.exe"
  default['chef-full']['ruby_dev_kit']['checksum']  = "6230d9e552e69823b83d6f81a5dadc06958d7a17e10c3f8e525fcc61b300b2ef"
else
  default['omnibus']['home']    = "/tmp/omnibus"
  default['chef-full']['home']  = "/opt/opscode"
end
