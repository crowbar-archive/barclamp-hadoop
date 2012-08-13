#
# Cookbook Name: hadoop
# Recipe: hadoop_service.rb
#
# Copyright (c) 2012 Dell Inc.
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

class HadoopService < ServiceObject
  
  #######################################################################
  # create_proposal - called on proposal creation.
  #######################################################################
  def create_proposal
    @logger.debug("hadoop create_proposal: entering")
    base = super
    
    # Compute the hadoop cluster node distribution.
    # You need at least 3 nodes (secondary name node, master name node
    # and slave node) to implement a baseline hadoop framework. The edge
    # node is added if the node count is 4 or higher. 
    secondary = [ ]
    master = [ ]
    edge = [ ]
    slaves = [ ]
    
    # Get the node list, find the admin node, put the hadoop secondary name node
    # on the crowbar admin node (as specified by the RA) and delete the admin
    # node from the array.
    nodes = Node.all
    nodes.each do |n|
      if n.is_admin?
        secondary << n.name if n.name
        nodes.delete(n)
      end
    end
    
    # Add the master, slave and edge nodes.
    if nodes.size == 1
      master << nodes[0].name if nodes[0].name
    elsif nodes.size == 2
      master << nodes[0].name if nodes[0].name
      slaves << nodes[1].name if nodes[1].name        
    elsif nodes.size == 3
      master << nodes[0].name if nodes[0].name
      slaves << nodes[1].name if nodes[1].name        
      edge << nodes[2].name if nodes[2].name
    elsif nodes.size > 3
      master << nodes[0].name if nodes[0].name
      slaves << nodes[1].name if nodes[1].name        
      edge << nodes[2].name if nodes[2].name
      nodes[3 .. nodes.size].each { |n|
        slaves << n.name if n.name
      }
    end
    
    # Add the proposal deployment elements
    master.each do |a|
      add_role_to_instance_and_node(a, base.name, "hadoop-masternamenode")
    end
    secondary.each do |a|
      add_role_to_instance_and_node(a, base.name, "hadoop-secondarynamenode")
    end
    edge.each do |a|
      add_role_to_instance_and_node(a, base.name, "hadoop-edgenode")
    end
    slaves.each do |a|
      add_role_to_instance_and_node(a, base.name, "hadoop-slavenode")
    end
    
    # @logger.debug("hadoop create_proposal: #{base.to_json}")
    @logger.debug("hadoop create_proposal: exiting")
    base
  end
  
  #######################################################################
  # apply_role_pre_chef_call - called before a chef role is applied.
  #######################################################################
  def apply_role_pre_chef_call(old_role, role, all_nodes)
    @logger.debug("hadoop apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty? 
    
    # Assign a public IP address to the edge node for external access.
    net_barclamp = Barclamp.find_by_name("network")
    tnodes = new_config.get_nodes_by_role("hadoop-edgenode")
    # Allocate the IP addresses for default, public, host.
    tnodes.each do |n|
      net_barclamp.operations(@logger).allocate_ip "default", "public", "host", n.name
    end
    
    @logger.debug("hadoop apply_role_pre_chef_call: leaving")
  end
  
end
