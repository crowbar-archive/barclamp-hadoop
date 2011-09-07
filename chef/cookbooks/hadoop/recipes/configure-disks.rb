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

=begin
# Configure the hadoop disks.
cookbook_file "/tmp/configure-disks.sh" do
  source "configure-disks.sh"
  owner node[:hadoop][:cluster][:process_file_system_owner]
  group node[:hadoop][:cluster][:global_file_system_group]
  backup false
  mode "0755"
end

execute "configure-disks" do
  command "/tmp/configure-disks.sh"
  action :run
end
=end

# Check the dfs_name_dir configuration. Data partitions are numbered 
# 1-N (i.e. /mnt/hdfs/hdfs01/meta1 - /mnt/hdfs/hdfs01/metaN).  
new_array = []
dfs_base_dir = node[:hadoop][:hdfs][:dfs_base_dir]  
hb = "#{dfs_base_dir}/hdfs01"
if File.exist?("#{hb}/meta6")
  new_array = ["#{hb}/meta1", "#{hb}/meta2", "#{hb}/meta3", "#{hb}/meta4", "#{hb}/meta5", "#{hb}/meta6" ] 
elsif File.exist?("#{hb}/meta5")
  new_array = [ "#{hb}/meta1", "#{hb}/meta2", "#{hb}/meta3", "#{hb}/meta4", "#{hb}/meta5" ] 
elsif File.exist?("#{hb}/meta4")
  new_array = [ "#{hb}/meta1", "#{hb}/meta2", "#{hb}/meta3", "#{hb}/meta4" ]
elsif File.exist?("#{hb}/meta3")
  new_array = [ "#{hb}/meta1", "#{hb}/meta2", "#{hb}/meta3" ]
elsif File.exist?("#{hb}/meta2")
  new_array = [ "#{hb}/meta1", "#{hb}/meta2" ]
elsif File.exist?("#{hb}/meta1")
  new_array = [ "#{hb}/meta1" ]
else
  new_array = [ "#{hb}/meta1" ]
end

# Update dfs_name_dir if changes have been detected.
if !new_array.nil? && new_array.length > 0
  node.set[:hadoop][:hdfs][:dfs_name_dir] = new_array
  node.save
end

#######################################################################
# Format the hadoop file system.
# exec 'hadoop namenode -format'.
# You can't be root (or you need to specify HADOOP_NAMENODE_USER).
#######################################################################

dfs_image_dir = "#{hb}/meta1/image"
hdfs_file_system_owner = node[:hadoop][:cluster][:hdfs_file_system_owner]

if (!File.exists?("#{hb}/meta1/image")) 
  # run HDFS format 
  Chef::Log.info("echo 'Y' | hadoop namenode -format #{hdfs_file_system_owner}") if debug
  
  # HDFS cannot run as root, so override the process owner
  execute "hdfs_format" do
    user hdfs_file_system_owner
    command "echo 'Y' | hadoop namenode -format"
  end
else 
  Chef::Log.info("skipping hdfs format") if debug
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:configure-disks") if debug
