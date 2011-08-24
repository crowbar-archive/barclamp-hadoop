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

# Install the packages.
package "hadoop-0.20" do
  # version node[:hadoop][:packages][:core][:version]
  action :install
end

package "hadoop-0.20-datanode" do
  action :install
  # version node[:hadoop][:packages][:core][:version]
end

package "hadoop-0.20-tasktracker" do
  action :install
  # version node[:hadoop][:packages][:core][:version]
end

# Create the logging directory with proper permissions. 
ldir = node[:hadoop][:env][:hadoop_log_dir]
directory ldir do
  owner "root"
  group "hadoop"
  mode "0775"
  recursive true
  action :create
  not_if "test -d #{ldir}"
end

# The only services we ever want to automatically restart upon a config change
# are these two so we define them up here.
service "hadoop-0.20-datanode" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

service "hadoop-0.20-tasktracker" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Drop the Hadoop configuration on the target host and restart the services.  
template "/etc/hadoop/conf/core-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "core-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install the HDFS component.
template "/etc/hadoop/conf/hdfs-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "hdfs-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
end

# Install the Map/Reduce component.
template "/etc/hadoop/conf/mapred-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "mapred-site.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install the hadoop ENV component.
template "/etc/hadoop/conf/hadoop-env.sh" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "hadoop-env.sh.erb"
  notifies :restart, resources(:service => "hadoop-0.20-datanode")
  notifies :restart, resources(:service => "hadoop-0.20-tasktracker")
end

# Install hadoop-metrics.properties.
template "/etc/hadoop/conf/hadoop-metrics.properties" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "hadoop-metrics.properties.erb"
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:default") if debug
