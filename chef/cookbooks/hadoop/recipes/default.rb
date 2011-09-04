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

# Configuration filter for our environment
env_filter = " AND environment:#{node[:hadoop][:config][:environment]}"

# Install the Oracle/SUN JAVA package (Hadoop requires the JDK).
package "jdk" do
  action :install
end

# Install the hadoop base package.
package "hadoop-0.20" do
  action :install
end

# Install the hadoop datanode service.
package "hadoop-0.20-datanode" do
  action :install
end

# Install the hadoop tasktracker service.
package "hadoop-0.20-tasktracker" do
  action :install
end

# Find the master name nodes (there should only be one). 
master_name_nodes = Array.new
search(:node, "roles:hadoop-masternamenode#{env_filter}") do |nmas|
  if !nmas[:fqdn].nil? && !nmas[:fqdn].empty?
    Chef::Log.info("GOT MASTER [#{nmas[:fqdn]}") if debug
    master_name_nodes << nmas[:fqdn]
  end
end
node[:hadoop][:cluster][:master_name_nodes] = master_name_nodes

# Check for errors
if master_name_nodes.length == 0
  Chef::Log.info("WARNING - Cannot find Hadoop master name node")
elsif master_name_nodes.length > 1
  Chef::Log.info("WARNING - More than one master name node found, using #{master_name_nodes[0]}")
end

# Find the secondary name nodes (there should only be one). 
secondary_name_nodes = Array.new
search(:node, "roles:hadoop-secondarynamenode#{env_filter}") do |nsec|
  if !nsec[:fqdn].nil? && !nsec[:fqdn].empty?
    Chef::Log.info("GOT SECONDARY [#{nsec[:fqdn]}") if debug
    secondary_name_nodes << nsec[:fqdn]
  end
end
node[:hadoop][:cluster][:secondary_name_nodes] = secondary_name_nodes

# Check for errors
if secondary_name_nodes.length == 0
  Chef::Log.info("WARNING - Cannot find Hadoop secondary name node")
elsif secondary_name_nodes.length > 1
  Chef::Log.info("WARNING - More than one secondary name node found, using #{secondary_name_nodes[0]}")
end

# Find the edge nodes. 
edge_nodes = Array.new
search(:node, "roles:hadoop-edgenode#{env_filter}") do |nedge|
  if !nedge[:fqdn].nil? && !nedge[:fqdn].empty?
    Chef::Log.info("GOT EDGE [#{nedge[:fqdn]}") if debug
    edge_nodes << nedge[:fqdn] 
  end
end
node[:hadoop][:cluster][:edge_nodes] = edge_nodes

# Find the slave nodes. 
slave_nodes = Array.new
search(:node, "roles:hadoop-slavenode#{env_filter}") do |nslave|
  if !nslave[:fqdn].nil? && !nslave[:fqdn].empty?
    Chef::Log.info("GOT SLAVE [#{nslave[:fqdn]}") if debug
    slave_nodes << nslave[:fqdn] 
  end
end
node[:hadoop][:cluster][:slave_nodes] = slave_nodes

if debug
  Chef::Log.info("MASTER_NAME_NODES    {" + node[:hadoop][:cluster][:master_name_nodes] .to_s + "}")
  Chef::Log.info("SECONDARY_NAME_NODES {" + node[:hadoop][:cluster][:secondary_name_nodes].to_s + "}")
  Chef::Log.info("EDGE_NODES           {" + node[:hadoop][:cluster][:edge_nodes].to_s + "}")
  Chef::Log.info("SLAVE_NODES          {" + node[:hadoop][:cluster][:slave_nodes].to_s + "}")
end

# Set the authoritative name node URI (i.e. hdfs://admin.example.com:8020).
node[:hadoop][:core][:fs_default_name] = "file:///"
if master_name_nodes.length > 0
  fqdn = master_name_nodes[0]
  port = node[:hadoop][:hdfs][:dfs_access_port]
  fs_default_name = "hdfs://#{fqdn}:#{port}"
  Chef::Log.info("fs_default_name #{fs_default_name}") if debug
  node[:hadoop][:core][:fs_default_name] = fs_default_name
end

node.save

# Create the logging directory and set ownership/permissions. 
ldir = node[:hadoop][:env][:hadoop_log_dir]
directory ldir do
  owner "root"
  group "hadoop"
  mode "0775"
  recursive true
  action :create
  not_if "test -d #{ldir}"
end

# The only services we ever want to automatically restart upon
# a config change are these two so we define them up here.
service "hadoop-0.20-datanode" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

service "hadoop-0.20-tasktracker" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Configure the master nodes.  
template "/etc/hadoop/conf/masters" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "masters.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Configure the slave nodes.  
template "/etc/hadoop/conf/slaves" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "slaves.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Drop the Hadoop configuration on the target host and restart the services.  
template "/etc/hadoop/conf/core-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "core-site.xml.erb"
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
