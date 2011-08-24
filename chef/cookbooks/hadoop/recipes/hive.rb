#
# Cookbook Name: hadoop
# Recipe: hive.rb
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
Chef::Log.info("BEGIN hadoop:hive") if debug

package "hadoop-hive" do
  action :install
  # version node[:hadoop][:packages][:hive][:version]
end

# Setup the hive config file.
template "/etc/hive/conf/hive-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
  source "hive-site.xml.erb"
end

# Installs the MySQL Java driver so Hive can talk to the MySQL-backed metastore.
bash "getMysqlConnectorJ" do
user "root"
  cwd "/tmp"
  code <<-EOH
  curl http://mysql.he.net/Downloads/Connector-J/mysql-connector-java-5.1.10.tar.gz | tar zxv mysql-connector-java-5.1.10/mysql-connector-java-5.1.10-bin.jar
  cp mysql-connector-java-5.1.10/mysql-connector-java-5.1.10-bin.jar /usr/lib/hive/lib/
  EOH
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:hive") if debug
