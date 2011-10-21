#
# Cookbook Name: hadoop
# Recipe: hadoop_service.rb
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

class HadoopService < ServiceObject
  
  #######################################################################
  # initialize - Initialize this service class.
  #######################################################################
  def initialize(thelogger)
    @bc_name = "hadoop"
    @logger = thelogger
  end
  
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
    nodes = NodeObject.all
    nodes.each do |n|
      if n.nil?
        nodes.delete(n)
        next
      end
      if n.admin?
        secondary << n[:fqdn] if n[:fqdn]
        nodes.delete(n)
      end
    end
    
    # Add the master, slave and edge nodes.
    if nodes.size == 1
      master << nodes[0][:fqdn] if nodes[0][:fqdn]
    elsif nodes.size == 2
      master << nodes[0][:fqdn] if nodes[0][:fqdn]
      slaves << nodes[1][:fqdn] if nodes[1][:fqdn]        
    elsif nodes.size == 3
      master << nodes[0][:fqdn] if nodes[0][:fqdn]
      slaves << nodes[1][:fqdn] if nodes[1][:fqdn]        
      edge << nodes[2][:fqdn] if nodes[2][:fqdn]
    elsif nodes.size > 3
      master << nodes[0][:fqdn] if nodes[0][:fqdn]
      slaves << nodes[1][:fqdn] if nodes[1][:fqdn]        
      edge << nodes[2][:fqdn] if nodes[2][:fqdn]
      nodes[3 .. nodes.size].each { |n|
        slaves << n[:fqdn] if n[:fqdn]
      }
    end
    
    # Add the proposal deployment elements
    base["deployment"]["hadoop"]["elements"] = { } 
    base["deployment"]["hadoop"]["elements"]["hadoop-masternamenode"] = master if master && !master.empty? 
    base["deployment"]["hadoop"]["elements"]["hadoop-secondarynamenode"] = secondary if secondary && !secondary.empty? 
    base["deployment"]["hadoop"]["elements"]["hadoop-edgenode"] = edge if edge && !edge.empty?  
    base["deployment"]["hadoop"]["elements"]["hadoop-slavenode"] = slaves if slaves && !slaves.empty?   
    
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
    
    # Make sure that the front-end pieces have public ip addreses.
    net_svc = NetworkService.new @logger
    [ "hadoop-edgenode" ].each do |element|
      tnodes = role.override_attributes["hadoop"]["elements"][element]
      next if tnodes.nil? or tnodes.empty?
      
      # Allocate the IP addresses for default, public, host.
      tnodes.each do |n|
        next if n.nil?
        net_svc.allocate_ip "default", "public", "host", n
      end
    end
    
    @logger.debug("hadoop apply_role_pre_chef_call: leaving")
  end
  
end
