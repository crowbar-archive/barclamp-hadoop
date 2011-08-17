#
# Cookbook Name: hadoop
# Recipe: flume-master.rb
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
Chef::Log.info("BEGIN hadoop:flume-masternode") if debug

# Install the flume flume package.
package "flume-master-0.9.3" do
  action :install
  # version node[:hadoop][:packages][:flume][:version]
end

# Create the flume configuration file.
template "/etc/hive/conf/flume-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "flume-site.xml.erb"
end

# Start the flume master node services.
service "flume-master-0.9.3" do
  action [ :enable, :start ]
  running true
  supports :status => true, :start => true, :stop => true, :restart => true
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:flume-masternode") if debug
