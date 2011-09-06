#
# Cookbook Name: hadoop
# Recipe: masternamenode.rb
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
Chef::Log.info("BEGIN hadoop:masternamenode") if debug

# Set the hadoop node type.
node[:hadoop][:cluster][:node_type] = "masternamenode"
node.save

# Install the name node package.
package "hadoop-0.20-namenode" do
  action :install
end

# Enables the Cloudera Service and Configuration Manager (SCM).
# Requires the installation of the Cloudera Enterprise Edition.
if node[:hadoop][:cloudera_enterprise_scm]
  include_recipe 'hadoop::cloudera-scm-server'
end

# Configure DFS host exclusion.
template "/etc/hadoop/conf/dfs.hosts.exclude" do
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  mode "0644"
  source "dfs.hosts.exclude.erb"
end

# Configure the disks
include_recipe 'hadoop::configure-disks'

=begin
# Ensure that the dfs_name_dir directories exists and have the correct permissions.
node[:hadoop][:hdfs][:dfs_name_dir].each do |dfs_name_dir|
  Chef::Log.info("mkdir #{dfs_name_dir}") if debug
  directory dfs_name_dir do
    owner node[:hadoop][:cluster][:hdfs_file_system_owner]
    group node[:hadoop][:cluster][:global_file_system_group]
    mode "0755"
    recursive true
    action :create
  end
end
=end

# Start the namenode services.
service "hadoop-0.20-namenode" do
  action [ :enable, :start ]
  running true
  supports :status => true, :start => true, :stop => true, :restart => true
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:masternamenode") if debug
