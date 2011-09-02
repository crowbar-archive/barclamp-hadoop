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

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("BEGIN hadoop:secondarynamenode") if debug

# Set the hadoop node type.
node[:hadoop][:cluster][:node_type] = "secondarynamenode"
node.save

# Make sure the dfs name secondary directory exists. 
dfs_name_secondary = "/var/lib/hadoop-0.20/dfs/namesecondary"
directory dfs_name_secondary do
  owner "hdfs"
  group "hadoop"
  mode "0755"
  recursive true
  action :create
  not_if "test -d #{dfs_name_secondary}"
end

# Install the secondary name node service.
package "hadoop-0.20-secondarynamenode" do
  action :install
end

# Make sure the fs_checkpoint_dir exists. 
node[:hadoop][:core][:fs_checkpoint_dir].each do |fs_checkpoint_dir|
  Chef::Log.info("mkdir #{fs_checkpoint_dir}") if debug
  directory fs_checkpoint_dir do
    owner "hdfs"
    group "hadoop"
    mode "0755"
    recursive true
    action :create
    not_if "test -d #{fs_checkpoint_dir}"
  end
end

# Start the secondary name node services.
service "hadoop-0.20-secondarynamenode" do
  action [ :enable, :start ]
  running true
  supports :status => true, :start => true, :stop => true, :restart => true
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:secondarynamenode") if debug
