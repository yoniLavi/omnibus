#!/usr/bin/env ruby

require 'systemu'
require 'net/ssh/multi'



BASE_PATH = File.dirname(__FILE__)
VM_BASE_PATH = File.expand_path("~/Documents/Virtual Machines.localized")
PROJECT = ARGV[0]
BUCKET = ARGV[1]
S3_ACCESS_KEY = ARGV[2]
S3_SECRET_KEY = ARGV[3]
SPECIFIC_HOSTS = ARGV[4..-1] || []

hosts_to_build = {
  'debian-6-i686' => "debian-6-i386.opscode.us",
  'debian-6-x86_64' => "debian-6-x86-64.opscode.us",
  'el-6-i686' => "sl-6-i386.opscode.us",
  'el-6-x86_64' => "sl-6-x86-64.opscode.us",
  'el-5.6-i686' => "centos-5-i386.opscode.us", 
  'el-5.6-x86_64' => "centos-5-x86-64.opscode.us",
  'ubuntu-1004-i686' => "ubuntu-1004-i386.opscode.us",
  'ubuntu-1004-x86_64' => "ubuntu-1004-x86-64.opscode.us",
  'ubuntu-1104-i686' => "ubuntu-1104-i386.opscode.us",
  'ubuntu-1104-x86_64' => "ubuntu-1104-x86-64.opscode.us",
  'openindiana-148-i686' => "openindiana-148-i386.opscode.us"
}

session = Net::SSH::Multi.start(:concurrent_connections => 6)
hosts_to_build.each do |host_type, build_host|
  if SPECIFIC_HOSTS.length > 0
    next unless SPECIFIC_HOSTS.include?(host_type)
  end
  session.use("root@#{build_host}")
end
channel = session.exec "/root/omnibus/build-omnibus.sh #{PROJECT} #{BUCKET} '#{S3_ACCESS_KEY}' '#{S3_SECRET_KEY}'" do |ch, stream, data|
  puts "[#{ch[:host]} : #{stream}] #{data}"
end
session.loop
channel.each do |c|
  puts "Failed on #{c[:host]}" if c[:exit_status] != 0
  run_command "scp root@#{c[:host]}:/tmp/omnibus.out '#{BASE_PATH}/build-output/#{c[:host]}.out'"
  puts "Build output captured."
end
session.close


#def run_command(cmd)
#  puts "Running #{cmd}"
#  status, stdout, stderr = systemu cmd 
#  raise "Command failed: #{stdout}, #{stderr}" if status.exitstatus != 0
#end
#
#build_status = Hash.new
#child_pids = Hash.new
#build_at_a_time = 5 
#total_hosts = hosts_to_build.keys.length
#current_count = 0 
#total_count = 0
#hosts_to_build.each do |host_type, build_host|
#  if SPECIFIC_HOSTS.length > 0
#    next unless SPECIFIC_HOSTS.include?(host_type)
#  end
#  total_count += 1
#  current_count += 1
#
#  pid = fork
#  if pid
#    child_pids[pid] = host_type
#    if current_count == build_at_a_time 
#      current_count = 0
#      Process.waitall.each do |pstat|
#        if pstat[1].exitstatus != 0
#          build_status[host_type] = "failed"
#          puts "Failed to build: #{child_pids[pstat[0]]}"
#        else
#          build_status[host_type] = "success"
#        end
#      end
#    end
#  else
#    puts "Building #{host_type}"
#    run_command "ssh root@#{build_host} /root/omnibus/build-omnibus.sh #{PROJECT} #{BUCKET} '#{S3_ACCESS_KEY}' '#{S3_SECRET_KEY}'"
#    run_command "scp root@#{build_host}:/tmp/omnibus.out '#{BASE_PATH}/build-output/#{host_type}.out'"
#    exit 0
#  end
#end
#
#Process.waitall.each do |pstat|
#  if pstat[1].exitstatus != 0
#    build_status[child_pids[pstat[0]]] = "failed"
#    puts "Failed to build: #{child_pids[pstat[0]]}"
#  else
#    build_status[child_pids[pstat[0]]] = "success"
#  end
#end
#
#build_status.each do |key, value|
#  puts "#{key}: #{value}"
#end
#
