#
# Cookbook Name: hadoop
# Recipe: masternamenode.rb
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
Chef::Log.info("HADOOP : BEGIN hadoop:masternamenode") if debug

# Local variables
process_owner = node[:hadoop][:cluster][:process_file_system_owner]
hdfs_owner = node[:hadoop][:cluster][:hdfs_file_system_owner]
mapred_owner = node[:hadoop][:cluster][:mapred_file_system_owner]
hadoop_group = node[:hadoop][:cluster][:global_file_system_group]

# Set the hadoop node type.
node[:hadoop][:cluster][:node_type] = "masternamenode"

# Install the name node package.
package "hadoop-0.20-namenode" do
  action :install
end

# Install the job tracker package. 
package "hadoop-0.20-jobtracker" do
  action :install
end

# Define our services so we can register notify events them.
service "hadoop-0.20-namenode" do
  supports :start => true, :stop => true, :status => true, :restart => true
  # Subscribe to common configuration change events (default.rb).
  subscribes :restart, resources(:directory => node[:hadoop][:env][:hadoop_log_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:hadoop_tmp_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:fs_s3_buffer_dir])
  subscribes :restart, resources(:template => "/etc/security/limits.conf")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/masters")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/slaves")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/core-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hdfs-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-metrics.properties")
end

# Start the jobtracker service.
service "hadoop-0.20-jobtracker" do
  supports :start => true, :stop => true, :status => true, :restart => true
  # Subscribe to common configuration change events (default.rb).
  subscribes :restart, resources(:directory => node[:hadoop][:env][:hadoop_log_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:hadoop_tmp_dir])
  subscribes :restart, resources(:directory => node[:hadoop][:core][:fs_s3_buffer_dir])
  subscribes :restart, resources(:template => "/etc/security/limits.conf")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/masters")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/slaves")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/core-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hdfs-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/mapred-site.xml")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-env.sh")
  subscribes :restart, resources(:template => "/etc/hadoop/conf/hadoop-metrics.properties")
end

# Configure DFS host exclusion.
template "/etc/hadoop/conf/dfs.hosts.exclude" do
  owner process_owner
  group hadoop_group
  mode "0644"
  source "dfs.hosts.exclude.erb"
  notifies :restart, resources(:service => "hadoop-0.20-namenode")
  notifies :restart, resources(:service => "hadoop-0.20-jobtracker")
end

# Setup the fair scheduler.
template "/etc/hadoop/conf/fair-scheduler.xml" do
  owner process_owner
  group hadoop_group
  mode "0644"
  source "fair-scheduler.xml.erb"
  notifies :restart, resources(:service => "hadoop-0.20-namenode")
  notifies :restart, resources(:service => "hadoop-0.20-jobtracker")
end

dfs_base_dir = node[:hadoop][:hdfs][:dfs_base_dir]  
hb = "#{dfs_base_dir}/hdfs01"

node.save

if node[:hadoop][:cluster][:valid_config]
  
  Chef::Log.info("HADOOP : CONFIGURATION VALID - STARTING MASTER NAME NODE SERVICES")
  
  #######################################################################
  # Format the hadoop file system(s).
  # exec 'hadoop namenode -format'.
  # You can't be root (or you need to specify HADOOP_NAMENODE_USER).
  #######################################################################
  
  if (!File.exists?("#{hb}/meta1/current/VERSION")) 
    
    Chef::Log.info("HADOOP : RUNNING HDFS FORMAT NOW") if debug
    
    # Initialize HDFS.
    # HDFS cannot run as root, so override the process owner (hdfs).
    # Execution sequence is important to avoid locking conditions;
    # a) Name node process must be down, job tracker process must be up.
    #    service hadoop-0.20-namenode stop
    #    service hadoop-0.20-jobtracker start
    # b) execute "echo 'Y' | hadoop namenode -format"
    # c) bring the name node process up
    #    service hadoop-0.20-namenode start
    # e) execute "hadoop fs -mkdir /mapred/system"
    # f) execute "hadoop fs -chown hdfs:hadoop /mapred/system"
    
    # Make sure the name node process is down.
    service "hadoop-0.20-namenode" do
      action :stop
    end 
    
    # Make sure the jobtracker service is up.
    service "hadoop-0.20-jobtracker" do
      action :start
    end 
    
    bash "hadoop-hdfs-format" do
      user hdfs_owner
      code <<-EOH
echo 'Y' | hadoop namenode -format
EOH
    end
    
    # Make sure the name node process is up.
    # {start|stop|status|restart|try-restart|upgrade|rollback}
    service "hadoop-0.20-namenode" do
      action :start
    end 
    
    bash "hadoop-hdfs-init" do
      user hdfs_owner
      code <<-EOH
hadoop fs -mkdir /mapred
hadoop fs -mkdir /mapred/system
hadoop fs -chown #{mapred_owner}:#{hadoop_group} /mapred
hadoop fs -chown #{mapred_owner}:#{hadoop_group} /mapred/system
hadoop fs -chmod 0775 /mapred
hadoop fs -chmod 0775 /mapred/system
EOH
    end
    
  else 
    Chef::Log.info("HADOOP : HDFS ALREADY FORMATTED") if debug
  end
  
  # Start the namenode service.
  service "hadoop-0.20-namenode" do
    action [ :enable, :start ] 
  end
  
  # Start the jobtracker service.
  service "hadoop-0.20-jobtracker" do
    action [ :enable, :start ] 
  end
  
else
  
  Chef::Log.info("HADOOP : CONFIGURATION INVALID - STOPPING MASTER NAME NODE SERVICES")
  
  # Start the namenode service.
  service "hadoop-0.20-namenode" do
    action [ :disable, :stop ] 
  end
  
  # Start the jobtracker service.
  service "hadoop-0.20-jobtracker" do
    action [ :disable, :stop ] 
  end
  
end

# Enables the Cloudera Service and Configuration Manager (SCM).
if node[:hadoop][:cloudera_enterprise_scm] == "true"
  include_recipe 'hadoop::cloudera-scm-server'
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("HADOOP : END hadoop:masternamenode") if debug
