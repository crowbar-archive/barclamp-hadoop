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

require File.join(File.dirname(__FILE__), '../libraries/common')

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("BEGIN hadoop:secondarynamenode") if debug

# Local variables
hdfs_owner = node[:hadoop][:cluster][:hdfs_file_system_owner]
hadoop_group = node[:hadoop][:cluster][:global_file_system_group]

# Set the hadoop node type.
node[:hadoop][:cluster][:node_type] = "secondarynamenode"
node.save

#######################################################################
# Note : We install the jobtracker package on the secondary name node
# but we do not start the process up.
#######################################################################

# Install the secondary name node service.
package "hadoop-0.20-secondarynamenode" do
  action :install
end

# Install the job tracker package. 
package "hadoop-0.20-jobtracker" do
  action :install
end

# Create dfs_name_secondary directory and set ownership/permissions. 
dfs_name_secondary = "/var/lib/hadoop-0.20/dfs/namesecondary"
directory dfs_name_secondary do
  owner hdfs_owner
  group hadoop_group
  mode "0775"
  recursive true
  action :create
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
  end
end

# Start the secondary name node services.
service "hadoop-0.20-secondarynamenode" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action [ :enable, :start ]
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:secondarynamenode") if debug
