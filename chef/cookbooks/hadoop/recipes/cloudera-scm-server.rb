#
# Cookbook Name: hadoop
# Recipe: cloudera-scm-server.rb
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
# Author: Paul Webster
#

include_recipe 'hadoop::mysql'

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("HADOOP : BEGIN hadoop:cloudera-scm-server") if debug

# Install the Cloudera Service and Configuration Manager (SCM) server.
package "cloudera-scm-server" do
  action :install
end

# Define the cloudera SCM server.
# /etc/init.d/cloudera-scm-server {start|stop|restart|status}
service "cloudera-scm-server" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action :enable 
end

# Install the JDBC J connector.
cookbook_file "/usr/share/cmf/lib/mysql-connector-java-5.1.18-bin.jar" do
  source "mysql-connector-java-5.1.18-bin.jar"  
  mode "0755"
  notifies :restart, resources(:service => "cloudera-scm-server")
end

# Setup the database
if !File.exists?("/usr/share/cmf/setup_complete")
  Chef::Log.info("HADOOP : Running SCM SQL setup") if debug
  bash "setup-database" do
    user "root"
    code <<-EOH
  mysqladmin -u root password 'crowbar'
  mysqladmin -u root -h $(hostname) password 'crowbar'
  mysql --user=root --password=crowbar -e "create database hue;"
  mysql --user=root --password=crowbar -e "grant all on hue.* to 'hue'@'localhost' identified by 'hue';"
  mysql --user=root --password=crowbar -e "create database oozie;"
  mysql --user=root --password=crowbar -e "grant all on oozie.* to 'oozie'@'localhost' identified by 'oozie';"
  mysql --user=root --password=crowbar -e "create database cmon;"
  mysql --user=root --password=crowbar -e "grant all on cmon.* to 'cmon'@'localhost' identified by 'cmon';"
  /usr/share/cmf/schema/scm_prepare_mysql.sh -p crowbar scm scm scm
  touch /usr/share/cmf/setup_complete
  exit 0  
  EOH
    notifies :restart, resources(:service => "cloudera-scm-server")
  end
else
    Chef::Log.info("HADOOP : SCM SQL setup already complete") if debug
end

# Start the cloudera SCM server.
service "cloudera-scm-server" do
  action :start 
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("HADOOP : END hadoop:cloudera-scm-server") if debug
