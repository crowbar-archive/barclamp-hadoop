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
debug = node["hadoop"]["debug"]
Chef::Log.info("HADOOP : BEGIN hadoop:configure-disks") if debug

# Find all the disks.
to_use_disks = []
all_disks = node["crowbar"]["disks"]
all_disks.each { |k,v|
  to_use_disks << k if v["usage"] == "Storage"  
}
Chef::Log.info("HADOOP : found disk: #{to_use_disks.join(':')}") if debug 

Chef::Log.info("HADOOP : CONFIGURING DISKS NOW") 
  
dfs_base_dir = node[:hadoop][:hdfs][:dfs_base_dir] 
# Walk over each of the disks, configuring it if we have to.
node[:hadoop][:devices] = []
node[:hadoop][:hdfs][:dfs_data_dir] = []
node[:hadoop][:mapred][:mapred_local_dir] = []
disk_cnt = 1
to_use_disks.sort.each { |k|
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
  disk = Hash.new
  disk[:name] = target_dev_part

  # Make sure that the kernel is aware of the current state of the 
  # drive partition tables.
  bash "Initial partprobe of #{target_dev}" do
    code "partprobe #{target_dev}"
  end

  # Create the first partition on the disk if it does not already exist.
  # This takes barely any time, so don't bother parallelizing it.
  # Create the first partition starting at 1MB into the disk, and use GPT.
  # This ensures that it is optimally aligned from an RMW cycle minimization
  # standpoint for just about everything -- RAID stripes, SSD erase blocks, 
  # 4k sector drives, you name it, and we can have >2TB volumes.
  bash "parted #{target_dev_part} into existence" do
    code <<-__END__
      parted -s #{target_dev} -- mklabel gpt mkpart primary ext2 1MB -1s
      partprobe #{target_dev}
      sleep 5
      dd if=/dev/zero of=#{target_dev_part} bs=1024 count=65
      __END__
    not_if "grep -q \'#{target_suffix}$\' /proc/partitions"
  end

  # Check to see if there is an ext3 volume on the first partition of the 
  # drive.  If not, fork and exec our formatter.  We will wait later.
  ruby_block "Lazy format #{target_dev_part}" do
    block do
      Chef::Log.info("HADOOP: formatting #{target_dev_part}") if debug
      ::Kernel.exec "mkfs.ext3 #{target_dev_part}" unless ::Process.fork
    end
    not_if "blkid  #{target_dev_part} -t \'TYPE=ext3\' &>/dev/null"
  end

  disk[:mount_point] = "#{dfs_base_dir}/hdfs01/drive#{disk_cnt}"
  disk[:size] = :remaining
  node[:hadoop][:devices] << disk.dup
  node[:hadoop][:hdfs][:dfs_data_dir] << ::File.join(disk[:mount_point],"data")
  node[:hadoop][:mapred][:mapred_local_dir] << ::File.join(disk[:mount_point],"mapred")
  disk_cnt = disk_cnt + 1
}

node.save
# Wait for formatting to finish

ruby_block "Wait for formats to finish" do
  block do
    Chef::Log.info("HADOOP: Waiting on all drives to finish formatting") if debug
    ::Process.waitall
  end
end
  
# Setup the mount points, if needed
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

#######################################################################
# End of recipe transactions
#######################################################################
Chef::Log.info("HADOOP : END hadoop:configure-disks") if debug
