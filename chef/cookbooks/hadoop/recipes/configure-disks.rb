#
# Cookbook Name: hadoop
# Recipe: configure-disks.rb
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
Chef::Log.info("BEGIN hadoop:configure-disks") if debug

# Configure the hadoop disks.
cookbook_file "/tmp/configure-disks.sh" do
  source "configure-disks.sh"
  owner "root"
  group "root"
  backup false
  mode "0755"
end

execute "configure-disks" do
  command "/tmp/configure-disks.sh"
  action :run
end

# Check the :dfs_name_dir configuration. Data partitions are numbered 
# 1-N (i.e. /mnt/hdfs/hdfs01/data1 - /mnt/hdfs/hdfs01/dataN).  
new_array = []
cur_array = node[:hadoop][:hdfs][:dfs_name_dir]
dfs_base_dir = node[:hadoop][:hdfs][:dfs_base_dir]  
hb = "#{dfs_base_dir}/hdfs01"
if File.exist?("#{hb}/data6")
  new_array = ["#{hb}/data1", "#{hb}/data2", "#{hb}/data3", "#{hb}/data4", "#{hb}/data5", "#{hb}/data6" ] 
elsif File.exist?("#{hb}/data5")
  new_array = [ "#{hb}/data1", "#{hb}/data2", "#{hb}/data3", "#{hb}/data4", "#{hb}/data5" ] 
elsif File.exist?("#{hb}/data4")
  new_array = [ "#{hb}/data1", "#{hb}/data2", "#{hb}/data3", "#{hb}/data4" ]
elsif File.exist?("#{hb}/data3")
  new_array = [ "#{hb}/data1", "#{hb}/data2", "#{hb}/data3" ]
elsif File.exist?("#{hb}/data2")
  new_array = [ "#{hb}/data1", "#{hb}/data2" ]
elsif File.exist?("#{hb}/data1")
  new_array = [ "#{hb}/data1" ]
else
  new_array = [ "#{hb}/data1" ]
end

# Update dfs_name_dir if changes have been detected.
if (!new_array.nil? && new_array.length > 0 && new_array != cur_array)
  node.set[:hadoop][:hdfs][:dfs_name_dir] = new_array
  node.save
end

#######################################################################
# Format the hadoop file system.
# exec 'hadoop namenode -format'.
# You can't be root (or you need to specify HADOOP_NAMENODE_USER).
#######################################################################
dfs_image_dir = "#{hb}/data1/image"
dfs_namenode_user = node[:hadoop][:hdfs][:dfs_namenode_user]

if (!File.exists?("#{hb}/data1/image")) 
  
  # Ensure that the parent directory exists
  dfs_name_dir = "#{hb}/data1"
  Chef::Log.info("mkdir #{dfs_name_dir}") if debug
  directory dfs_name_dir do
    owner "hdfs"
    group "hadoop"
    mode "0755"
    recursive true
    action :create
    not_if "test -d #{dfs_name_dir}"
  end
  
  # run HDFS format 
  Chef::Log.info("echo 'Y' | hadoop namenode -format #{dfs_namenode_user}") if debug
  
  # HDFS cannot run as root, so override the process owner
  execute "hdfs_format" do
    user dfs_namenode_user
    command "echo 'Y' | hadoop namenode -format"
  end
else 
  Chef::Log.info("skipping hdfs format") if debug
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:configure-disks") if debug
