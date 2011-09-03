#
# Cookbook Name: hadoop
# Recipe: jobtracker.rb
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
Chef::Log.info("BEGIN hadoop:jobtracker") if debug

# Install the job tracker package. 
package "hadoop-0.20-jobtracker" do
  action :install
end

# Setup the fair scheduler.
template "/etc/hadoop/conf/fair-scheduler.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "fair-scheduler.xml.erb"
end

# Configure the disks.
include_recipe 'hadoop::configure-disks'

# Ensure that the mapred_local_dir directories exists and have the correct permissions.
node[:hadoop][:mapred][:mapred_local_dir].each do |localDir|
  directory localDir do
    owner "mapred"
    group "hadoop"
    mode "0755"
    recursive true
    action :create
  end
end

# Start the jobtracker service.
service "hadoop-0.20-jobtracker" do
  action [ :enable, :start ]
  running true
  supports :status => true, :start => true, :stop => true, :restart => true
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:jobtracker") if debug
