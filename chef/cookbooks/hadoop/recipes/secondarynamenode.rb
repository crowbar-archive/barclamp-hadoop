#
# Cookbook Name: hadoop
# Recipe: secondarynamenode.rb
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
Chef::Log.info("HADOOP : BEGIN hadoop:secondarynamenode") if debug

# Local variables
hdfs_owner = node[:hadoop][:cluster][:hdfs_file_system_owner]
hadoop_group = node[:hadoop][:cluster][:global_file_system_group]

# Set the hadoop node type.
node[:hadoop][:cluster][:node_type] = "secondarynamenode"
node.save

# Install the secondary name node service. We install the jobtracker
# package on the secondary name node but do not start the service up.
package "hadoop-0.20-secondarynamenode" do
  action :install
end

package "hadoop-0.20-jobtracker" do
  action :install
end

# Define our services so we can register notify events them.
# Make sure the job tracker doesn't start up on reboot.
service "hadoop-0.20-secondarynamenode" do
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

# Install the jobtracker package but keep it disabled.
service "hadoop-0.20-jobtracker" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action :disable
end

# Create dfs_name_secondary directory and set ownership/permissions. 
dfs_name_secondary = "/var/lib/hadoop-0.20/dfs/namesecondary"
directory dfs_name_secondary do
  owner hdfs_owner
  group hadoop_group
  mode "0775"
  recursive true
  action :create
  notifies :restart, resources(:service => "hadoop-0.20-secondarynamenode")
end

# Create fs_checkpoint_dir and set ownership/permissions (/tmp/hadoop-metadata). 
fs_checkpoint_dir = node[:hadoop][:core][:fs_checkpoint_dir] 
fs_checkpoint_dir.each do |path|
  directory path do
    owner hdfs_owner
    group hadoop_group
    recursive true
    mode "0775"
    action :create
    notifies :restart, resources(:service => "hadoop-0.20-secondarynamenode")
  end
end

# Start the secondary name node service.
if node[:hadoop][:cluster][:valid_config]
  Chef::Log.info("HADOOP : CONFIGURATION VALID - STARTING SECONDARY NAME NODE SERVICES")
  service "hadoop-0.20-secondarynamenode" do
    action [ :enable, :start ] 
  end
else
  Chef::Log.info("HADOOP : CONFIGURATION INVALID - STOPPING SECONDARY NAME NODE SERVICES")
  service "hadoop-0.20-secondarynamenode" do
    action [ :disable, :stop ] 
  end
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("HADOOP : END hadoop:secondarynamenode") if debug
