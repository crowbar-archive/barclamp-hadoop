#
# Cookbook Name: hadoop
# Attributes: default.rb
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
# Crowbar barclamp configuration parameters.
#######################################################################

# Crowbar configuration enviroment.
default[:hadoop][:config] = {}
default[:hadoop][:config][:environment] = "hadoop-config-default"
default[:hadoop][:debug] = true

# Enables the Cloudera Service and Configuration Manager (SCM).
# Requires the installation of the Cloudera Enterprise Edition.
default[:hadoop][:cloudera_enterprise_scm] = "false"

# Cluster attributes.
default[:hadoop][:cluster] = {}
default[:hadoop][:cluster][:node_type] = ""
default[:hadoop][:cluster][:master_name_nodes] = [ ]
default[:hadoop][:cluster][:secondary_name_nodes] = [ ]
default[:hadoop][:cluster][:edge_nodes] = [ ]
default[:hadoop][:cluster][:slave_nodes] = [ ]

# File system ownership settings.
default[:hadoop][:cluster][:global_file_system_group] = "hadoop"
default[:hadoop][:cluster][:process_file_system_owner] = "root"
default[:hadoop][:cluster][:mapred_file_system_owner] = "mapred"
default[:hadoop][:cluster][:hdfs_file_system_owner] = "hdfs"
default[:hadoop][:cluster][:hdfs_file_system_group] = "hdfs"

default[:hadoop][:cluster][:disk_configured] = false
default[:hadoop][:cluster][:valid_config] = true
