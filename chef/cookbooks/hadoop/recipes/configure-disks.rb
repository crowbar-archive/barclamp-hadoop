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
# Author: andi abes
#

#######################################################################
# Begin recipe transactions
#######################################################################
debug = node[:hadoop][:debug]
Chef::Log.info("HADOOP : BEGIN hadoop:configure-disks") if debug

if !node[:hadoop][:cluster][:disk_configured]
  
  Chef::Log.info("HADOOP : CONFIGURING DISKS NOW") 
  node[:hadoop][:cluster][:disk_configured] = true
  node.save
  
  # Install parted utility program.
  cookbook_file "/opt/parted" do
    source "parted"  
    mode '0755'
  end
  
  # Find all the disks.
  to_use_disks = {}
  all_disks = node["crowbar"]["disks"]
  all_disks.each { |k,v|
    b = binding()
    to_use_disks[k]=v if v["usage"] == "Storage"  
  }
  Chef::Log.info("HADOOP : found disk: #{to_use_disks.keys.join(':')}") if debug 
  
  # Partition the disks.
  node[:hadoop][:devices] = []
  disk_cnt = 0
  to_use_disks.each { |k,v| 
    
    # By default, we will format first partition.
    target_suffix= k + "1" 
    target_dev = "/dev/#{k}"
    target_dev_part = "/dev/#{target_suffix}"
    
    # Protect against OS's that confuse ohai. if the device isn't there,
    # don't try to use it.
    if ! File.exists?(target_dev)
      Chef::Log.warn("HADOOP : device: #{target_dev} doesn't seem to exist. ignoring")
      next
    end
    
    # Publish the disk devices. dfs_base_dir=/mnt/hdfs
    disk_cnt = disk_cnt +1    
    dfs_base_dir = node[:hadoop][:hdfs][:dfs_base_dir] 
    mount_point = "#{dfs_base_dir}/hdfs01/data#{disk_cnt}"
    
    hadoop_disk target_dev do
      part [{ :type => "ext3", :size => :remaining} ]
      action :ensure_exists
      cmd "/opt/parted"
    end
    
    node[:hadoop][:devices] <<  {:name=>target_dev_part, :size=> :remaining, :mount_point=> mount_point}
  }
  
  execute "sync" do
    command "sync ; sleep 5"
  end
  
  # Create all the actions required to format all the file systems, but
  # don't run them rather, the ruby block that follows spawns parallel
  # threads to perform the formatting concurrently.
  actions = []
  node[:hadoop][:devices].each { |k| 
    a = execute "mkfs_ext3 #{k[:name]}" do
      command "echo 'formatting #{k[:name]}' ; mkfs.ext3 -F #{k[:name]}"    
      returns [0, 1]
      not_if "tune2fs -l #{k[:name]}"  # if there's a superblock - assume good.
      action :nothing
    end
    actions << a
  }  
  
  # Spawn threads as part of the convergence phase, and format the file
  # systems in parallel. Wait for activity to complete.
  ruby_block "format_disks" do
    block do
      threads = []
      actions.each { | a| 
        threads << Thread.new { |t| a.run_action(:run)}
      }
      threads.each { |t| t.join }
    end  
  end
  
  # Setup the mount points
  node[:hadoop][:devices].each { |k|   
    directory k[:mount_point] do
      recursive true
      action :create
    end
    
    mount k[:mount_point]  do  
      device k[:name]
      options "noatime,nodiratime"
      dump 0  
      pass 0 # no FSCK testing.
      fstype "ext3"
      action [:mount, :enable]
    end  
  }
else
  Chef::Log.info("HADOOP : DISK ALREADY CONFIGURED - SKIPPING") 
end

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("HADOOP : END hadoop:configure-disks") if debug
