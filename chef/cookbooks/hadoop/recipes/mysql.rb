#
# Cookbook Name: hadoop
# Recipe: mysql-jdbc.rb
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

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("HADOOP : BEGIN hadoop:mysql") if debug

# Install MYSQL - Required by the SCM server.
package "mysql-server" do
  action :install
end

# Start the MYSQL server.
# /etc/init.d/mysqld {start|stop|status|condrestart|restart}
service "mysqld" do
  supports :start => true, :stop => true, :status => true, :restart => true
  action [ :enable, :start ] 
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("HADOOP : END hadoop:mysql") if debug
