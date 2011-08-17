#
# Cookbook Name: hadoop
# Attributes: hdfs-site.rb
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
# Crowbar internal parameters.
#######################################################################
default[:hadoop][:hdfs][:dfs_base_dir] = "/mnt/hdfs"
default[:hadoop][:hdfs][:dfs_access_port] = "8020"

#######################################################################
# Site specific HDFS settings (/etc/hadoop/conf/hdfs-site.xml).
#######################################################################

# The access time for HDFS file is precise upto this value. The default
# value is 1 hour. Setting a value of 0 disables access times for HDFS.
default[:hadoop][:hdfs][:dfs_access_time_precision] = "3600000"

# Specifies the maximum amount of bandwidth that each datanode can utilize
# for the balancing purpose in term of the number of bytes per second.
default[:hadoop][:hdfs][:dfs_balance_bandwidthPerSec] = "1048576"

# Interval in minutes at which namenode updates its access keys.
default[:hadoop][:hdfs][:dfs_block_access_key_update_interval] = "600"

# If "true", access tokens are used as capabilities for accessing
# datanodes. If "false", no access tokens are checked on accessing
# datanodes.
default[:hadoop][:hdfs][:dfs_block_access_token_enable] = "false"

# The lifetime of access tokens in minutes.
default[:hadoop][:hdfs][:dfs_block_access_token_lifetime] = "600"

# The default block size for new files.
default[:hadoop][:hdfs][:dfs_block_size] = "67108864"

# Delay for first block report in seconds.
default[:hadoop][:hdfs][:dfs_blockreport_initialDelay] = ""

# Determines block reporting interval in milliseconds.
default[:hadoop][:hdfs][:dfs_blockreport_intervalMsec] = "3600000"

# The number of retries for writing blocks to the data nodes, before we
# signal failure to the application.
default[:hadoop][:hdfs][:dfs_client_block_write_retries] = "3"

# Determines where on the local filesystem an DFS data node should store
# its blocks. If this is a comma-delimited list of directories, then data
# will be stored in all named directories, typically on different devices.
# Directories that do not exist are ignored.
default[:hadoop][:hdfs][:dfs_data_dir] = "${hadoop.tmp.dir}/dfs/data"

# The address where the datanode server will listen to. If the port is 0
# then the server will start on a free port.
default[:hadoop][:hdfs][:dfs_datanode_address] = "0.0.0.0:50010"

# Permissions for the directories on on the local filesystem where the DFS
# data node store its blocks. The permissions can either be octal or
# symbolic.
default[:hadoop][:hdfs][:dfs_datanode_data_dir_perm] = "755"

# The name of the Network Interface from which a data node should report
# its IP address.
default[:hadoop][:hdfs][:dfs_datanode_dns_interface] = "default"

# The host name or IP address of the name server (DNS) which a DataNode
# should use to determine the host name used by the NameNode for
# communication and display purposes.
default[:hadoop][:hdfs][:dfs_datanode_dns_nameserver] = "default"

# Reserved space in bytes per volume. Always leave this much space free for
# non dfs use.
default[:hadoop][:hdfs][:dfs_datanode_du_reserved] = ""

# The number of volumes that are allowed to fail before a datanode stops
# offering service. By default any volume failure will cause a datanode to
# shutdown.
default[:hadoop][:hdfs][:dfs_datanode_failed_volumes_tolerated] = ""

# The number of server threads for the datanode.
default[:hadoop][:hdfs][:dfs_datanode_handler_count] = "3"

# The datanode http server address and port. If the port is 0 then the
# server will start on a free port.
default[:hadoop][:hdfs][:dfs_datanode_http_address] = "0.0.0.0:50075"


default[:hadoop][:hdfs][:dfs_datanode_https_address] = "0.0.0.0:50475"

# The datanode ipc server address and port. If the port is 0 then the
# server will start on a free port.
default[:hadoop][:hdfs][:dfs_datanode_ipc_address] = "0.0.0.0:50020"

# The number of bytes to view for a file on the browser.
default[:hadoop][:hdfs][:dfs_default_chunk_view_size] = "32768"

# Disk usage statistics refresh interval in msec.
default[:hadoop][:hdfs][:dfs_df_interval] = "60000"

# Determines datanode heartbeat interval in seconds.
default[:hadoop][:hdfs][:dfs_heartbeat_interval] = "3"

# Names a file that contains a list of hosts that are permitted to connect
# to the namenode. The full pathname of the file must be specified. If the
# value is empty, all hosts are permitted.
default[:hadoop][:hdfs][:dfs_hosts] = ""

# Names a file that contains a list of hosts that are not permitted to
# connect to the namenode. The full pathname of the file must be specified.
# If the value is empty, no hosts are excluded.
default[:hadoop][:hdfs][:dfs_hosts_exclude] = ""

# The address and the base port where the dfs namenode web ui will listen
# on. If the port is 0 then the server will start on a free port.
default[:hadoop][:hdfs][:dfs_http_address] = "0.0.0.0:50070"


default[:hadoop][:hdfs][:dfs_https_address] = "0.0.0.0:50470"

# Resource file from which ssl client keystore information will be
# extracted.
default[:hadoop][:hdfs][:dfs_https_client_keystore_resource] = "ssl-client.xml"

# Decide if HTTPS(SSL) is supported on HDFS.
default[:hadoop][:hdfs][:dfs_https_enable] = "false"

# Whether SSL client certificate authentication is required.
default[:hadoop][:hdfs][:dfs_https_need_client_auth] = "false"

# Resource file from which ssl server keystore information will be
# extracted.
default[:hadoop][:hdfs][:dfs_https_server_keystore_resource] = "ssl-server.xml"

# The maximum number of files, directories and blocks dfs supports. A value
# of zero indicates no limit to the number of objects that dfs supports.
default[:hadoop][:hdfs][:dfs_max_objects] = ""

# Determines where on the local filesystem the DFS name node should store
# the name table(fsimage). If this is a comma-delimited list of directories
# then the name table is replicated in all of the directories, for
# redundancy.
default[:hadoop][:hdfs][:dfs_name_dir] = [ "${hadoop.tmp.dir}/dfs/name" ]

# Determines where on the local filesystem the DFS name node should store
# the transaction (edits) file. If this is a comma-delimited list of
# directories then the transaction file is replicated in all of the
# directories, for redundancy. Default value is same as dfs.name.dir.
default[:hadoop][:hdfs][:dfs_name_edits_dir] = [ "${dfs.name.dir}" ]

# Namenode periodicity in seconds to check if decommission is complete.
default[:hadoop][:hdfs][:dfs_namenode_decommission_interval] = "30"

# The number of nodes namenode checks if decommission is complete in each
# dfs.namenode.decommission.interval.
default[:hadoop][:hdfs][:dfs_namenode_decommission_nodes_per_interval] = "5"

# The update interval for master key for delegation tokens in the namenode
# in milliseconds.
default[:hadoop][:hdfs][:dfs_namenode_delegation_key_update_interval] = "86400000"

# The maximum lifetime in milliseconds for which a delegation token is
# valid.
default[:hadoop][:hdfs][:dfs_namenode_delegation_token_max_lifetime] = "604800000"

# The renewal interval for delegation token in milliseconds.
default[:hadoop][:hdfs][:dfs_namenode_delegation_token_renew_interval] = "86400000"

# The number of server threads for the namenode.
default[:hadoop][:hdfs][:dfs_namenode_handler_count] = "10"

# The logging level for dfs namenode. Other values are "dir"(trace
# namespace mutations), "block"(trace block under/over replications and
# block creations/deletions), or "all".
default[:hadoop][:hdfs][:dfs_namenode_logging_level] = "info"

# If "true", enable permission checking in HDFS. If "false", permission
# checking is turned off, but all other behavior is unchanged. Switching
# from one parameter value to the other does not change the mode, owner or
# group of files or directories.
default[:hadoop][:hdfs][:dfs_permissions] = "true"

# The name of the group of super-users.
default[:hadoop][:hdfs][:dfs_permissions_supergroup] = "supergroup"

# Default block replication. The actual number of replications can be
# specified when the file is created. The default is used if replication is
# not specified in create time.
default[:hadoop][:hdfs][:dfs_replication] = "3"

# Decide if chooseTarget considers the target's load or not.
default[:hadoop][:hdfs][:dfs_replication_considerLoad] = "true"

# The periodicity in seconds with which the namenode computes repliaction
# work for datanodes.
default[:hadoop][:hdfs][:dfs_replication_interval] = "3"

# Maximal block replication.
default[:hadoop][:hdfs][:dfs_replication_max] = "512"

# Minimal block replication.
default[:hadoop][:hdfs][:dfs_replication_min] = "1"

# Determines extension of safe mode in milliseconds after the threshold
# level is reached.
default[:hadoop][:hdfs][:dfs_safemode_extension] = "30000"

# Specifies the percentage of blocks that should satisfy the minimal
# replication requirement defined by dfs.replication.min. Values less than
# or equal to 0 mean not to start in safe mode. Values greater than 1 will
# make safe mode permanent.
default[:hadoop][:hdfs][:dfs_safemode_threshold_pct] = "0.999f"

# The secondary namenode http server address and port. If the port is 0
# then the server will start on a free port.
default[:hadoop][:hdfs][:dfs_secondary_http_address] = "0.0.0.0:50090"

# Does HDFS allow appends to files? This is currently set to false because
# there are bugs in the "append code" and is not supported in any prodction
# cluster.
default[:hadoop][:hdfs][:dfs_support_append] = "false"

# The user account used by the web interface. Syntax:
# USERNAME,GROUP1,GROUP2, ...
default[:hadoop][:hdfs][:dfs_web_ugi] = "webuser,webgroup"
