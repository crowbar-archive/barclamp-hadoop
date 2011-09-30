#
# Cookbook Name: hadoop
# Attributes: core-site.rb
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
# Hadoop core configuration parameters (/etc/hadoop/conf/core-site.xml).
#######################################################################

# Determines where on the local filesystem the DFS secondary name node
# should store the temporary images to merge. If this is a comma-delimited
# list of directories then the image is replicated in all of the
# directories for redundancy.
default[:hadoop][:core][:fs_checkpoint_dir] = [ "/tmp/hadoop-metadata" ]

# Determines where on the local filesystem the DFS secondary name node
# should store the temporary edits to merge. If this is a comma-delimited
# list of directoires then teh edits is replicated in all of the
# directoires for redundancy.
# DEFAULT: ${fs.checkpoint.dir}
default[:hadoop][:core][:fs_checkpoint_edits_dir] = [ "/tmp/hadoop-metadata" ]

# The number of seconds between two periodic checkpoints.
default[:hadoop][:core][:fs_checkpoint_period] = "3600"

# The size of the current edit log (in bytes) that triggers a periodic
# checkpoint even if the fs.checkpoint.period hasn't expired.
default[:hadoop][:core][:fs_checkpoint_size] = "67108864"

# The name of the default file system. A URI whose scheme and authority
# determine the FileSystem implementation. The uri's scheme determines the
# config property (fs.SCHEME.impl) naming the FileSystem implementation
# class. The uri's authority is used to determine the host, port, etc. for
# a filesystem (example - "hdfs://namenode.example.com:8020").
default[:hadoop][:core][:fs_default_name] = "file:///"

# The FileSystem for file: uris.
default[:hadoop][:core][:fs_file_impl] = "org.apache.hadoop.fs.LocalFileSystem"

# The FileSystem for ftp: uris.
default[:hadoop][:core][:fs_ftp_impl] = "org.apache.hadoop.fs.ftp.FTPFileSystem"

# The filesystem for Hadoop archives.
default[:hadoop][:core][:fs_har_impl] = "org.apache.hadoop.fs.HarFileSystem"

# Don't cache 'har' filesystem instances.
default[:hadoop][:core][:fs_har_impl_disable_cache] = "true"

# The FileSystem for hdfs: uris.
default[:hadoop][:core][:fs_hdfs_impl] = "org.apache.hadoop.hdfs.DistributedFileSystem"
default[:hadoop][:core][:fs_hftp_impl] = "org.apache.hadoop.hdfs.HftpFileSystem"
default[:hadoop][:core][:fs_hsftp_impl] = "org.apache.hadoop.hdfs.HsftpFileSystem"

# The FileSystem for kfs: uris.
default[:hadoop][:core][:fs_kfs_impl] = "org.apache.hadoop.fs.kfs.KosmosFileSystem"

# The FileSystem for ramfs: uris.
default[:hadoop][:core][:fs_ramfs_impl] = "org.apache.hadoop.fs.InMemoryFileSystem"

# Block size to use when writing files to S3.
default[:hadoop][:core][:fs_s3_block_size] = "67108864"

# Determines where on the local filesystem the S3 filesystem should store
# files before sending them to S3 (or after retrieving them from S3).
# DEFAULT: "${hadoop.tmp.dir}/s3"
default[:hadoop][:core][:fs_s3_buffer_dir] = "/tmp/hadoop-crowbar/s3"

# The FileSystem for s3: uris.
default[:hadoop][:core][:fs_s3_impl] = "org.apache.hadoop.fs.s3.S3FileSystem"

# The maximum number of retries for reading or writing files to S3, before
# we signal failure to the application.
default[:hadoop][:core][:fs_s3_maxRetries] = "4"

# The number of seconds to sleep between each S3 retry.
default[:hadoop][:core][:fs_s3_sleepTimeSeconds] = "10"

# The FileSystem for s3n: (Native S3) uris.
default[:hadoop][:core][:fs_s3n_impl] = "org.apache.hadoop.fs.s3native.NativeS3FileSystem"

# Number of minutes between trash checkpoints. If zero, the trash feature
# is disabled.
default[:hadoop][:core][:fs_trash_interval] = "1440"

# A comma separated list of class names. Each class in the list must extend
# org.apache.hadoop.http.FilterInitializer. The corresponding Filter will
# be initialized. Then, the Filter will be applied to all user facing jsp
# and servlet web pages. The ordering of the list defines the ordering of
# the filters.
default[:hadoop][:core][:hadoop_http_filter_initializers] = ""

# The max number of log files.
default[:hadoop][:core][:hadoop_logfile_count] = "10"

# The max size of each log file.
default[:hadoop][:core][:hadoop_logfile_size] = "10000000"

# Should native hadoop libraries, if present, be used.
default[:hadoop][:core][:hadoop_native_lib] = "true"

# SocketFactory to use to connect to a DFS. If null or empty, use
# hadoop.rpc.socket.class.default. This socket factory is also used by
# DFSClient to create sockets to DataNodes.
default[:hadoop][:core][:hadoop_rpc_socket_factory_class_ClientProtocol] = ""

# Default SocketFactory to use. This parameter is expected to be formatted
# as "package.FactoryClassName".
default[:hadoop][:core][:hadoop_rpc_socket_factory_class_default] = "org.apache.hadoop.net.StandardSocketFactory"

# Possible values are simple (no authentication), and kerberos.
default[:hadoop][:core][:hadoop_security_authentication] = "simple"

# Is service-level authorization enabled?.
default[:hadoop][:core][:hadoop_security_authorization] = "false"

# Class for user to group mapping (get groups for a given user).
default[:hadoop][:core][:hadoop_security_group_mapping] = "org.apache.hadoop.security.ShellBasedUnixGroupsMapping"

# NativeIO maintains a cache from UID to UserName. This is the timeout for
# an entry in that cache.
default[:hadoop][:core][:hadoop_security_uid_cache_secs] = "14400"

# Address (host:port) of the SOCKS server to be used by the
# SocksSocketFactory.
default[:hadoop][:core][:hadoop_socks_server] = ""

# A base for other temporary directories.
# DEFAULT: "/tmp/hadoop-${user.name}"
default[:hadoop][:core][:hadoop_tmp_dir] = "/tmp/hadoop-crowbar"

# The default implementation of Hash. Currently this can take one of the
# two values: 'murmur' to select MurmurHash and 'jenkins' to select
# JenkinsHash.
default[:hadoop][:core][:hadoop_util_hash_type] = "murmur"

# The number of bytes per checksum. Must not be larger than
# io.file.buffer.size.
default[:hadoop][:core][:io_bytes_per_checksum] = "512"

# A list of the compression codec classes that can be used for
# compression/decompression.
default[:hadoop][:core][:io_compression_codecs] = "org.apache.hadoop.io.compress.DefaultCodec,org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.BZip2Codec"

# The size of buffer for use in sequence files. The size of this buffer
# should probably be a multiple of hardware page size (4096 on Intel x86),
# and it determines how much data is buffered during read and write
# operations.
default[:hadoop][:core][:io_file_buffer_size] = "65536"

# The rate of false positives in BloomFilter-s used in BloomMapFile. As
# this value decreases, the size of BloomFilter-s increases exponentially.
# This value is the probability of encountering false positives (default is
# 0.5%).
default[:hadoop][:core][:io_mapfile_bloom_error_rate] = "0.005"

# The size of BloomFilter-s used in BloomMapFile. Each time this many keys
# is appended the next BloomFilter will be created (inside a
# DynamicBloomFilter). Larger values minimize the number of filters, which
# slightly increases the performance, but may waste too much space if the
# total number of keys is usually much smaller than this number.
default[:hadoop][:core][:io_mapfile_bloom_size] = "1048576"

# The minimum block size for compression in block compressed SequenceFiles.
default[:hadoop][:core][:io_seqfile_compress_blocksize] = "1000000"

# Should values of block-compressed SequenceFiles be decompressed only when
# necessary.
default[:hadoop][:core][:io_seqfile_lazydecompress] = "true"

# The limit on number of records to be kept in memory in a spill in
# SequenceFiles.Sorter.
default[:hadoop][:core][:io_seqfile_sorter_recordlimit] = "1000000"

# A list of serialization classes that can be used for obtaining
# serializers and deserializers.
default[:hadoop][:core][:io_serializations] = "org.apache.hadoop.io.serializer.WritableSerialization"

# If true, when a checksum error is encountered while reading a sequence
# file, entries are skipped, instead of throwing an exception.
default[:hadoop][:core][:io_skip_checksum_errors] = "false"

# Indicates the number of retries a client will make to establish a server
# connection.
default[:hadoop][:core][:ipc_client_connect_max_retries] = "10"

# The maximum time in msec after which a client will bring down the
# connection to the server.
default[:hadoop][:core][:ipc_client_connection_maxidletime] = "10000"

# Defines the threshold number of connections after which connections will
# be inspected for idleness.
default[:hadoop][:core][:ipc_client_idlethreshold] = "4000"

# Defines the maximum number of clients to disconnect in one go.
default[:hadoop][:core][:ipc_client_kill_max] = "10"

# Turn on/off Nagle's algorithm for the TCP socket connection on the
# client. Setting to true disables the algorithm and may decrease latency
# with a cost of more/smaller packets.
default[:hadoop][:core][:ipc_client_tcpnodelay] = "false"

# Indicates the length of the listen queue for servers accepting client
# connections.
default[:hadoop][:core][:ipc_server_listen_queue_size] = "128"

# Turn on/off Nagle's algorithm for the TCP socket connection on the
# server. Setting to true disables the algorithm and may decrease latency
# with a cost of more/smaller packets.
default[:hadoop][:core][:ipc_server_tcpnodelay] = "false"

# The limit on the size of cache you want to keep, set by default to 10GB.
# This will act as a soft limit on the cache directory for out of band
# data.
default[:hadoop][:core][:local_cache_size] = "10737418240"

# The default implementation of the DNSToSwitchMapping. It invokes a script
# specified in topology.script.file.name to resolve node names. If the
# value for topology.script.file.name is not set, the default value of
# DEFAULT_RACK is returned for all node names.
default[:hadoop][:core][:topology_node_switch_mapping_impl] = "org.apache.hadoop.net.ScriptBasedMapping"

# The script name that should be invoked to resolve DNS names to
# NetworkTopology names. Example: the script would take host.foo.bar as an
# argument, and return /rack1 as the output.
default[:hadoop][:core][:topology_script_file_name] = ""

# The max number of args that the script configured with
# topology.script.file.name should be run with. Each arg is an IP address.
default[:hadoop][:core][:topology_script_number_args] = "100"

# If set to true, the web interfaces of JT and NN may contain actions, such
# as kill job, delete file, etc., that should not be exposed to public.
# Enable this option if the interfaces are only reachable by those who have
# the right authorization.
default[:hadoop][:core][:webinterface_private_actions] = "false"
