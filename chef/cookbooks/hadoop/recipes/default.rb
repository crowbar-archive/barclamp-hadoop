#
# Cookbook Name: hadoop
# Recipe: default.rb
#
# Copyright (c) 2011 Dell Inc.
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

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("BEGIN hadoop:default") if debug

# Install the Oracle/SUN JAVA package.
package "jdk" do
  action :install
end

# Install the hadoop base package.
package "hadoop-0.20" do
  action :install
end

# Install the hadoop datanode package.
package "hadoop-0.20-datanode" do
  action :install
end

# Install the hadoop tasktracker package.
package "hadoop-0.20-tasktracker" do
  action :install
end

# Create the logging directory with proper permissions. 
ldir = node[:hadoop][:env][:hadoop_log_dir]
directory ldir do
  owner "root"
  group "hadoop"
  mode "0775"
  recursive true
  action :create
  not_if "test -d #{ldir}"
end

# The only services we ever want to automatically restart upon a config change
# are these two so we define them up here.
service "hadoop-0.20-datanode" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

service "hadoop-0.20-tasktracker" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Base filter for our environment
env_filter = " AND environment:#{node[:hadoop][:config][:environment]}"

# Find the master name node 
master_nodes = Array.new
search(:node, "roles:hadoop-masternamenode#{env_filter}") do |n|
  master_nodes << n[:fqdn] if n[:fqdn] 
end
node[:hadoop][:cluster][:masters] = master_nodes

# Find the slave nodes 
slave_nodes = Array.new
search(:node, "roles:hadoop-slavenode#{env_filter}") do |n|
  slave_nodes << n[:fqdn] if n[:fqdn] 
end
node[:hadoop][:cluster][:slaves] = slave_nodes

if debug
  Chef::Log.info("MASTER  {" + master_nodes.to_s + "}")
  Chef::Log.info("PRIMARY {" + master_nodes[0] + "}")
  Chef::Log.info("SLAVES  {" + slave_nodes.to_s + "}")
end

# Set the authoritative name node URI (i.e. hdfs://admin.example.com:8020).
node[:hadoop][:core][:fs_default_name] = "file:///"
if master_nodes.length > 0
  fqdn = master_nodes[0]
  port = node[:hadoop][:hdfs][:dfs_access_port]
  fs_default_name = "hdfs://#{fqdn}:#{port}"
  Chef::Log.info("fs_default_name #{fs_default_name}") if debug
  node[:hadoop][:core][:fs_default_name] = fs_default_name
end

node.save

# Configure the master and slave nodes.  
template "/etc/hadoop/conf/masters" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "masters.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

template "/etc/hadoop/conf/slaves" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "slaves.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install the HDFS component.
template "/etc/hadoop/conf/hdfs-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "hdfs-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
end

# Install the Map/Reduce component.
template "/etc/hadoop/conf/mapred-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "mapred-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install the hadoop ENV component.
template "/etc/hadoop/conf/hadoop-env.sh" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "hadoop-env.sh.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install hadoop-metrics.properties.
template "/etc/hadoop/conf/hadoop-metrics.properties" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "hadoop-metrics.properties.erb"
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:default") if debug
