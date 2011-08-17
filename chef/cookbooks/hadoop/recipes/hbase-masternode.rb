#
# Cookbook Name: hadoop
# Recipe: hbase-masternode.rb
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
Chef::Log.info("BEGIN hadoop:hbase-masternode") if debug

# Configure init.d.
template "/etc/init.d/hbase_master" do
  source "hbase-master_init_d.erb"
  mode 0755
  owner 'root'
  group 'root'
  variables(
        :hbase_dir => node[:hadoop][:hbase][:hbase_dir],
        :hadoop_user => node[:hadoop][:hbase][:hbase_user]
  )
end

# Restart the service.
service "hbase_master" do
  supports :start => true, :stop => true, :restart => true
  action [ :enable, :start ]
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:hbase") if debug
