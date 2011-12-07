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

####
# The Chef User that services run as
####
# The username for the chef services user
default['chef_server']['user']['username'] = "chef"
# The shell for the chef services user
default['chef_server']['user']['shell'] = "/bin/sh"
# The home directory for the chef services user
default['chef_server']['user']['home'] = "/opt/opscode/embedded"

####
# CouchDB 
####
# Enable/disable the CouchDB service
default['chef_server']['couchdb']['enable'] = true 
# The directory for CouchDB data
default['chef_server']['couchdb']['dir'] = "/var/opt/opscode/couchdb"
# The port to listen on
default['chef_server']['couchdb']['port'] = '5984'
# The IP Address to bind on - use 0.0.0.0 for everything 
default['chef_server']['couchdb']['bind_address'] = '127.0.0.1'
default['chef_server']['couchdb']['max_document_size'] = '4294967296'
default['chef_server']['couchdb']['max_attachment_chunk_size'] = '4294967296'
default['chef_server']['couchdb']['os_process_timeout'] = '300000'
default['chef_server']['couchdb']['max_dbs_open'] = 10000
default['chef_server']['couchdb']['delayed_commits'] = 'true'
default['chef_server']['couchdb']['batch_save_size'] = 1000 
default['chef_server']['couchdb']['batch_save_interval'] = 1000 
default['chef_server']['couchdb']['log_level'] = 'error' 
default['chef_server']['couchdb']['reduce_limit'] = 'false' 

####
# RabbitMQ
####
default['chef_server']['rabbitmq']['enable'] = true
default['chef_server']['rabbitmq']['dir'] = "/var/opt/opscode/rabbitmq"
default['chef_server']['rabbitmq']['vhost'] = '/chef'
default['chef_server']['rabbitmq']['user'] = 'chef'
default['chef_server']['rabbitmq']['password'] = 'chefrocks'
default['chef_server']['rabbitmq']['node_ip_address'] = '127.0.0.1'
default['chef_server']['rabbitmq']['node_port'] = '5672'

####
# Chef Solr
####
default['chef_server']['chef-solr']['enable'] = true
default['chef_server']['chef-solr']['dir'] = "/var/opt/opscode/chef-solr"
default['chef_server']['chef-solr']['heap_size'] = "256M" 
default['chef_server']['chef-solr']['java_opts'] = ""
default['chef_server']['chef-solr']['url'] = "http://localhost:8983"
default['chef_server']['chef-solr']['ip_address'] = '127.0.0.1'
default['chef_server']['chef-solr']['port'] = '8983'
default['chef_server']['chef-solr']['ram_buffer_size'] = 200 
default['chef_server']['chef-solr']['merge_factor'] = 100
default['chef_server']['chef-solr']['max_merge_docs'] = 2147483647
default['chef_server']['chef-solr']['max_field_length'] = 100000
default['chef_server']['chef-solr']['max_commit_docs'] = 1000
default['chef_server']['chef-solr']['commit_interval'] = 60000 # in ms
default['chef_server']['chef-solr']['poll_seconds'] = 20 # slave -> master poll interval in seconds, max of 60 (see solrconfig.xml.erb)

####
# Chef Expander
####
default['chef_server']['chef-expander']['enable'] = true
default['chef_server']['chef-expander']['dir'] = "/var/opt/opscode/chef-expander"
default['chef_server']['chef-expander']['consumer_id'] = "default" 
default['chef_server']['chef-expander']['nodes'] = 2 

####
# Chef Server API
####
default['chef_server']['chef-server-api']['enable'] = true
default['chef_server']['chef-server-api']['dir'] = "/var/opt/opscode/chef-server-api"
default['chef_server']['chef-server-api']['url'] = "http://127.0.0.1:4000" 
default['chef_server']['chef-server-api']['listen'] = '127.0.0.1:4000'
default['chef_server']['chef-server-api']['backlog'] = 1024
default['chef_server']['chef-server-api']['tcp_nodelay'] = true 
default['chef_server']['chef-server-api']['worker_timeout'] = 3600 
default['chef_server']['chef-server-api']['validation_client_name'] = "chef"
default['chef_server']['chef-server-api']['umask'] = "0022"
default['chef_server']['chef-server-api']['worker_processes'] = node["cpu"]["total"].to_i
default['chef_server']['chef-server-api']['web_ui_client_name'] = "chef-webui"
default['chef_server']['chef-server-api']['web_ui_admin_user_name'] = "admin"
default['chef_server']['chef-server-api']['web_ui_admin_default_password'] = "p@ssw0rd1"

####
# Chef Server WebUI
####
default['chef_server']['chef-server-webui']['enable'] = true
default['chef_server']['chef-server-webui']['dir'] = "/var/opt/opscode/chef-server-webui"
default['chef_server']['chef-server-webui']['url'] = "http://127.0.0.1:4040" 
default['chef_server']['chef-server-webui']['listen'] = '127.0.0.1:4040'
default['chef_server']['chef-server-webui']['backlog'] = 1024
default['chef_server']['chef-server-webui']['tcp_nodelay'] = true 
default['chef_server']['chef-server-webui']['worker_timeout'] = 3600 
default['chef_server']['chef-server-webui']['validation_client_name'] = "chef"
default['chef_server']['chef-server-webui']['umask'] = "0022"
default['chef_server']['chef-server-webui']['worker_processes'] = node["cpu"]["total"].to_i
default['chef_server']['chef-server-webui']['web_ui_client_name'] = "chef-webui"
default['chef_server']['chef-server-webui']['web_ui_admin_user_name'] = "admin"
default['chef_server']['chef-server-webui']['web_ui_admin_default_password'] = "p@ssw0rd1"

####
# Nginx
####
default['chef_server']['nginx']['enable'] = true
default['chef_server']['nginx']['dir'] = "/var/opt/opscode/nginx"
default['chef_server']['nginx']['ssl_port'] = 443
default['chef_server']['nginx']['server_name'] = node['fqdn']
default['chef_server']['nginx']['ssl_certificate'] = nil 
default['chef_server']['nginx']['ssl_certificate_key'] = nil 
default['chef_server']['nginx']['ssl_country_name'] = "US"
default['chef_server']['nginx']['ssl_state_name'] = "WA"
default['chef_server']['nginx']['ssl_locality_name'] = "Seattle"
default['chef_server']['nginx']['ssl_company_name'] = "YouCorp"
default['chef_server']['nginx']['ssl_organizational_unit_name'] = "Operations"
default['chef_server']['nginx']['ssl_email_address'] = "you@example.com"
default['chef_server']['nginx']['worker_processes'] = node['cpu']['total'].to_i
default['chef_server']['nginx']['worker_connections'] = node['cpu']['total'].to_i
default['chef_server']['nginx']['sendfile'] = 'on'
default['chef_server']['nginx']['tcp_nopush'] = 'on'
default['chef_server']['nginx']['tcp_nodelay'] = 'on'
default['chef_server']['nginx']['gzip'] = "on"               
default['chef_server']['nginx']['gzip_http_version'] = "1.0"
default['chef_server']['nginx']['gzip_comp_level'] = "2"   
default['chef_server']['nginx']['gzip_proxied'] = "any"   
default['chef_server']['nginx']['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript" ] 
default['chef_server']['nginx']['keepalive_timeout'] = 65 

