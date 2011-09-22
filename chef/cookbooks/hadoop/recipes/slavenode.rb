#
# Cookbook Name: hadoop
# Recipe: slavenode.rb
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

require File.join(File.dirname(__FILE__), '../libraries/common')

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("BEGIN hadoop:slavenode") if debug

# Local variables
hdfs_owner = node[:hadoop][:cluster][:hdfs_file_system_owner]
mapred_owner = node[:hadoop][:cluster][:mapred_file_system_owner]
hadoop_group = node[:hadoop][:cluster][:global_file_system_group]

# Set the hadoop node type.
node[:hadoop][:cluster][:node_type] = "slavenode"
node.save

# Install the data node package.
package "hadoop-0.20-datanode" do
  action :install
end

# Install the task tracker package.
package "hadoop-0.20-tasktracker" do
  action :install
end

# Define our services so we can can fire notify events against them.
service "hadoop-0.20-datanode" do
  supports :start => true, :stop => true, :status => true, :restart => true
end

service "hadoop-0.20-tasktracker" do
  supports :start => true, :stop => true, :status => true, :restart => true
end

# Configure the data node disk mount points (dfs_data_dir).
# These were set by configure-disks.rb. 
dfs_data_dir = Array.new
node[:hadoop][:devices].each do |rec| 
  Chef::Log.info("mount_point #{rec[:mount_point]}") if debug
  dfs_data_dir << rec[:mount_point]
end
node[:hadoop][:hdfs][:dfs_data_dir] = dfs_data_dir 

# Set the dfs_data_dir ownership/permissions (/mnt/hdfs/hdfs01/data1).
# The directories are already created by the configure-disks.rb script,
# but we need to fix up the file system permissions.
dfs_data_dir = node[:hadoop][:hdfs][:dfs_data_dir]
dfs_data_dir.each do |path|
  directory path do
    owner hdfs_owner
    group hadoop_group
    mode "0755"
    recursive true
    action :create
    notifies :restart, resources(:service => "hadoop-0.20-datanode")
    notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
  end
  # Make the lost+found file readable by HDFS or it will complain
  # about read access when the data node processes are started.
  lost_found = "#{path}/lost+found"
  file "#{lost_found}" do
    owner "root"
    group "root"
    mode "0755"
    only_if { ::File.exists?("#{lost_found}") }
  end
end

# Create mapred_local_dir and set ownership/permissions (/var/lib/hadoop-0.20/cache/mapred/mapred/local).
mapred_local_dir = node[:hadoop][:mapred][:mapred_local_dir]
mapred_local_dir.each do |path|
  directory path do
    owner mapred_owner
    group hadoop_group
    mode "0755"
    recursive true
    action :create
    notifies :restart, resources(:service => "hadoop-0.20-datanode")
    notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
  end
end

# Start the data node services.
service "hadoop-0.20-datanode" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action [ :enable, :start ]
end

# Start the task tracker.
service "hadoop-0.20-tasktracker" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action [ :enable, :start ]
end

# Enables the Cloudera Service and Configuration Manager (SCM).
# Requires the installation of the Cloudera Enterprise Edition.
if node[:hadoop][:cloudera_enterprise_scm]
  include_recipe 'hadoop::cloudera-scm-agent'
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:slavenode") if debug
