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
master_name_node_objects = Array.new
search(:node, "roles:hadoop-masternamenode#{env_filter}") do |nmas|
  if !nmas[:fqdn].nil? && !nmas[:fqdn].empty?
    Chef::Log.info("GOT MASTER [#{nmas[:fqdn]}") if debug
    master_name_nodes << nmas[:fqdn]
    master_name_node_objects << nmas
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

# Map/Reduce setup
# mapred.job.tracker needs to be set to the IP of the Master Node running job tracker
# mapred.job.tracker.http.address needs to also be set to the above IP
master_node_ip = "0.0.0.0"
if !master_name_node_objects.nil? && master_name_node_objects.length > 0
  master_node_ip = BarclampLibrary::Barclamp::Inventory.get_network_by_type(master_name_node_objects[0],"admin").address
end
Chef::Log.info("master_node_ip #{master_node_ip}") if debug

# The host and port that the MapReduce job tracker runs at. If "local",
# then jobs are run in-process as a single map and reduce task.
node[:hadoop][:mapred][:mapred_job_tracker] = "#{master_node_ip}:50030"

# The job tracker http server address and port the server will listen on.
# If the port is 0 then the server will start on a free port "0.0.0.0:50030".
node[:hadoop][:mapred][:mapred_job_tracker_http_address] = "#{master_node_ip}:50031"

node.save

# Create the logging directory and set ownership/permissions. 
hadoop_log_dir = node[:hadoop][:env][:hadoop_log_dir]
directory hadoop_log_dir do
  Chef::Log.info("mkdir #{hadoop_log_dir}") if debug
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0775"
  recursive true
  action :create
end

# Create the dfs name directory and set ownership/permissions. 
# NOTE: "directory recursive" does not set the directory permissions correctly. 
node[:hadoop][:hdfs][:dfs_name_dir].each do |dfs_name_dir|
  dir = ""
  dfs_name_dir.split('/').each do |d|
    next if (d.nil? || d.empty?)
    dir = "#{dir}/#{d}"
    if !File.exists?(dir)
      Chef::Log.info("mkdir #{dir}") if debug
      directory dir do
        owner node[:hadoop][:cluster][:hdfs_file_system_owner]
        group node[:hadoop][:cluster][:global_file_system_group]
        mode "0755"
        action :create
      end
    end
  end
end

# Create the mapred local directory and set ownership/permissions.
# NOTE: "directory recursive" does not set the directory permissions correctly. 
node[:hadoop][:mapred][:mapred_local_dir].each do |mapred_local_dir|
  dir = ""
  mapred_local_dir.split('/').each do |d|
    next if (d.nil? || d.empty?)
    dir = "#{dir}/#{d}"
    if !File.exists?(dir)
      Chef::Log.info("mkdir #{dir}") if debug
      directory dir do
        owner node[:hadoop][:cluster][:mapred_file_system_owner]
        group node[:hadoop][:cluster][:global_file_system_group]
        mode "0755"
        action :create
      end
    end
  end
end

# Create the mapred_system_dir and set ownership/permissions. 
# NOTE: "directory recursive" does not set the directory permissions correctly. 
dir = ""
node[:hadoop][:mapred][:mapred_system_dir].split('/').each do |d|
  next if (d.nil? || d.empty?)
  dir = "#{dir}/#{d}"
  if !File.exists?(dir)
    Chef::Log.info("mkdir #{dir}") if debug
    directory dir do
      owner node[:hadoop][:cluster][:mapred_file_system_owner]
      group node[:hadoop][:cluster][:global_file_system_group]
      mode "0755"
      action :create
    end
  end
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
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0644"
  source "masters.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Configure the slave nodes.  
template "/etc/hadoop/conf/slaves" do
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0644"
  source "slaves.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Drop the Hadoop configuration on the target host and restart the services.  
template "/etc/hadoop/conf/core-site.xml" do
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0644"
  source "core-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install the HDFS component.
template "/etc/hadoop/conf/hdfs-site.xml" do
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0644"
  source "hdfs-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
end

# Install the Map/Reduce component.
template "/etc/hadoop/conf/mapred-site.xml" do
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0644"
  source "mapred-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install the hadoop ENV component.
template "/etc/hadoop/conf/hadoop-env.sh" do
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0755"
  source "hadoop-env.sh.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install hadoop-metrics.properties.
template "/etc/hadoop/conf/hadoop-metrics.properties" do
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0644"
  source "hadoop-metrics.properties.erb"
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:default") if debug
