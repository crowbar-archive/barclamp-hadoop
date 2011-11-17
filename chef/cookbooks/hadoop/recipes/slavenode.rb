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
# Author: Paul Webster
#

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("HADOOP : BEGIN hadoop:slavenode") if debug

# Local variables.
hdfs_owner = node[:hadoop][:cluster][:hdfs_file_system_owner]
mapred_owner = node[:hadoop][:cluster][:mapred_file_system_owner]
hadoop_group = node[:hadoop][:cluster][:global_file_system_group]
hdfs_group = node[:hadoop][:cluster][:hdfs_file_system_group]

# Install the data node package.
package "hadoop-0.20-datanode" do
  action :install
end

# Install the task tracker package.
package "hadoop-0.20-tasktracker" do
  action :install
end

# Define our services so we can register notify events them.
service "hadoop-0.20-datanode" do
  supports :start => true, :stop => true, :status => true, :restart => true
  # Subscribe to common configuration change events (default.rb).
  subscribes :restart, resources(:directory => node[:hadoop][:env][:hadoop_log_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:hadoop_tmp_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:fs_s3_buffer_dir])
  subscribes :restart, resources(:template => "/etc/security/limits.conf")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/masters")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/slaves")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/core-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hdfs-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-metrics.properties")
end

# Start the task tracker service.
service "hadoop-0.20-tasktracker" do
  supports :start => true, :stop => true, :status => true, :restart => true
  # Subscribe to common configuration change events (default.rb).
  subscribes :restart, resources(:directory => node[:hadoop][:env][:hadoop_log_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:hadoop_tmp_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:fs_s3_buffer_dir])
  subscribes :restart, resources(:template => "/etc/security/limits.conf")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/masters")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/slaves")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/core-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hdfs-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-metrics.properties")
end

# Set the dfs_data_dir ownership/permissions.
# The directories are already created by the configure-disks.rb script,
# but we need to fix up the file system permissions.
node[:hadoop][:hdfs][:dfs_data_dir].each do |path|
  directory path do
    owner hdfs_owner
    group hdfs_group
    mode "0755"
    recursive true
    action :create
    notifies :restart, resources(:service => "hadoop-0.20-datanode")
    notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
  end
end

# Create mapred_local_dir and set ownership/permissions.
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

if node[:hadoop][:cluster][:valid_config]
  Chef::Log.info("HADOOP : CONFIGURATION VALID - STARTING DATANODE SERVICES")
  # Start the data node service.
  service "hadoop-0.20-datanode" do
    action [ :enable, :start ] 
  end
  
  # Start the task tracker service.
  service "hadoop-0.20-tasktracker" do
    action [ :enable, :start ] 
  end
else
  Chef::Log.info("HADOOP : CONFIGURATION INVALID - STOPPING DATANODE SERVICES")
  
  # Stop the data node service.
  service "hadoop-0.20-datanode" do
    action [ :disable, :stop ] 
  end
  
  # Stop the task tracker service.
  service "hadoop-0.20-tasktracker" do
    action [ :disable, :stop ] 
  end
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("HADOOP : END hadoop:slavenode") if debug
