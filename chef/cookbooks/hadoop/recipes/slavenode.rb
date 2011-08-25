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

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("BEGIN hadoop:slavenode") if debug

# Set the hadoop node type.
node[:hadoop][:node_type] = "slavenode"
node.save

# Install the data node package.
package "hadoop-0.20-datanode" do
  action :install
end

# Install the task tracker package.
package "hadoop-0.20-tasktracker" do
  action :install
end

# Configure the disks.
include_recipe 'hadoop::configure-disks'

# Setup the DFS data directory. 
node[:hadoop][:hdfs][:dfs_data_dir].each do |dataDir|
  directory dataDir do
    owner "hdfs"
    group "hadoop"
    mode "0755"
    recursive true
    action :create
  end
end

# Setup the MAP/REDUCE local directory. 
node[:hadoop][:mapred][:mapred_local_dir].each do |localDir|
  directory localDir do
    owner "mapred"
    group "hadoop"
    mode "0755"
    recursive true
    action :create
  end
end

# Start the data node services.
service "hadoop-0.20-datanode" do
  action [ :enable, :start ]
  running true
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Start the task tracker.
service "hadoop-0.20-tasktracker" do
  action [ :enable, :start ]
  running true
  supports :status => true, :start => true, :stop => true, :restart => true
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:slavenode") if debug
