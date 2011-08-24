#
# Cookbook Name: hadoop
# Recipe: hive-sql.rb
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
Chef::Log.info("BEGIN hadoop:hive-sql") if debug

# Install mysql and mysql-server packages.
package "mysql" do
  action :install
end

package "mysql-server" do
  action :install
end

# Start the services.
service "mysqld" do
  action [ :enable, :start ]
  running true
  supports :status => true, :start => true, :stop => true, :restart => true
end

bash "initdb" do
  user "root"
  code <<-EOH
  service mysqld start
  mysqladmin -u root password 'crowbar'
  mysqladmin -u root -h $(hostname) password 'crowbar'
  mysql -h localhost -u crowbar -pcrowbar -e"CREATE USER 'hadoop'@'localhost' IDENTIFIED BY 'hadoop'; GRANT ALL PRIVILEGES ON *.* TO 'hadoop'@'localhost' WITH GRANT OPTION;"
  mysql -h localhost -u crowbar -pcrowbar -e"CREATE USER 'hadoop'@'$(hostname)' IDENTIFIED BY 'hadoop'; GRANT ALL PRIVILEGES ON *.* TO 'hadoop'@'$(hostname)' WITH GRANT OPTION;"
  exit 0
  EOH
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("END hadoop:hive-sql") if debug
