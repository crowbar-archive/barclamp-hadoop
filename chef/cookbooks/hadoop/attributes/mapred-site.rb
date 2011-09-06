#
# Cookbook Name: hadoop
# Attributes: mapred-site.rb
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
# Crowbar internal parameters (non proposal configurable).
#######################################################################

#######################################################################
# Site specific MAP/REDUCE settings (/etc/hadoop/conf/mapred-site.xml).
#######################################################################

# If job tracker is static the history files are stored in this single well
# known place. If No value is set it is in the local file system at
# ${hadoop.log.dir}/history.
# DEFAULT: ${hadoop.log.dir}/history
default[:hadoop][:mapred][:hadoop_job_history_location] = ""

# User can specify a location to store the history files of a particular
# job. If nothing is specified, the logs are stored in output directory.
# The files are stored in "_logs/history/" in the directory. User can stop
# logging by giving the value "none".
default[:hadoop][:mapred][:hadoop_job_history_user_location] = ""

# SocketFactory to use to connect to a Map/Reduce master (JobTracker). If
# null or empty, then use hadoop.rpc.socket.class.default.
default[:hadoop][:mapred][:hadoop_rpc_socket_factory_class_JobSubmissionProtocol] = ""

# Number of index entries to skip between each entry. Zero by default.
# Setting this to values larger than zero can facilitate opening large map
# files using less memory.
default[:hadoop][:mapred][:io_map_index_skip] = ""

# The number of streams to merge at once while sorting files. This
# determines the number of open file handles.
default[:hadoop][:mapred][:io_sort_factor] = "10"

# The total amount of buffer memory to use while sorting files, in
# megabytes. By default, gives each merge stream 1MB, which should minimize
# seeks.
default[:hadoop][:mapred][:io_sort_mb] = "100"

# The percentage of io.sort.mb dedicated to tracking record boundaries. Let
# this value be r, io.sort.mb be x. The maximum number of records collected
# before the collection thread must block is equal to (r * x) / 4.
default[:hadoop][:mapred][:io_sort_record_percent] = "0.05"

# The soft limit in either the buffer or record collection buffers. Once
# reached, a thread will begin to spill the contents to disk in the
# background. Note that this does not imply any chunking of data to the
# spill. A value less than 0.5 is not recommended.
default[:hadoop][:mapred][:io_sort_spill_percent] = "0.80"

# Indicates how many times hadoop should attempt to contact the
# notification URL.
default[:hadoop][:mapred][:job_end_retry_attempts] = ""

# Indicates time in milliseconds between notification URL retry calls.
default[:hadoop][:mapred][:job_end_retry_interval] = "30000"

# The filter for controlling the output of the task's userlogs sent to the
# console of the JobClient. The permissible options are: NONE, KILLED,
# FAILED, SUCCEEDED and ALL.
default[:hadoop][:mapred][:jobclient_output_filter] = "FAILED"

# Should the files for failed tasks be kept. This should only be used on
# jobs that are failing, because the storage is never reclaimed. It also
# prevents the map outputs from being erased from the reduce directory as
# they are consumed.
default[:hadoop][:mapred][:keep_failed_task_files] = "false"

# The default sort class for sorting keys.
default[:hadoop][:mapred][:map_sort_class] = "org.apache.hadoop.util.QuickSort"

# Specifies whether ACLs should be checked for authorization of users for
# doing various queue and job level operations. ACLs are disabled by
# default. If enabled, access control checks are made by JobTracker and
# TaskTracker when requests are made by users for queue operations like
# submit job to a queue and kill a job in the queue and job operations like
# viewing the job-details (See mapreduce.job.acl-view-job) or for modifying
# the job (See mapreduce.job.acl-modify-job) using Map/Reduce APIs, RPCs or
# via the console and web user interfaces.
default[:hadoop][:mapred][:mapred_acls_enabled] = "false"

# User added environment variables for the task tracker child processes.
# Example : 1) A=foo This will set the env variable A to foo 2) B=$B:c This
# is inherit tasktracker's B env variable.
default[:hadoop][:mapred][:mapred_child_env] = ""

# Java opts for the task tracker child processes. The following symbol, if
# present, will be interpolated: @taskid@ is replaced by current TaskID.
# Any other occurrences of '@' will go unchanged. For example, to enable
# verbose gc logging to a file named for the taskid in /tmp and to set the
# heap maximum to be a gigabyte, pass a 'value' of: -Xmx1024m -verbose:gc
# -Xloggc:/tmp/@taskid@.gc The configuration variable mapred.child.ulimit
# can be used to control the maximum virtual memory of the child processes.
default[:hadoop][:mapred][:mapred_child_java_opts] = "-Xmx200m"

# To set the value of tmp directory for map and reduce tasks. If the value
# is an absolute path, it is directly assigned. Otherwise, it is prepended
# with task's working directory. The java tasks are executed with option
# -Djava.io.tmpdir='the absolute path of the tmp dir'. Pipes and streaming
# are set with environment variable, TMPDIR='the absolute path of the tmp
# dir'.
default[:hadoop][:mapred][:mapred_child_tmp] = "./tmp"

# The maximum virtual memory, in KB, of a process launched by the
# Map-Reduce framework. This can be used to control both the Mapper/Reducer
# tasks and applications using Hadoop Pipes, Hadoop Streaming etc. By
# default it is left unspecified to let cluster admins control it via
# limits.conf and other such relevant mechanisms. Note: mapred.child.ulimit
# must be greater than or equal to the -Xmx passed to JavaVM, else the VM
# might not start.
default[:hadoop][:mapred][:mapred_child_ulimit] = ""

# The size, in terms of virtual memory, of a single map slot in the
# Map-Reduce framework, used by the scheduler. A job can ask for multiple
# slots for a single map task via mapred.job.map.memory.mb, upto the limit
# specified by mapred.cluster.max.map.memory.mb, if the scheduler supports
# the feature. The value of -1 indicates that this feature is turned off.
default[:hadoop][:mapred][:mapred_cluster_map_memory_mb] = "-1"

# The maximum size, in terms of virtual memory, of a single map task
# launched by the Map-Reduce framework, used by the scheduler. A job can
# ask for multiple slots for a single map task via
# mapred.job.map.memory.mb, upto the limit specified by
# mapred.cluster.max.map.memory.mb, if the scheduler supports the feature.
# The value of -1 indicates that this feature is turned off.
default[:hadoop][:mapred][:mapred_cluster_max_map_memory_mb] = "-1"

# The maximum size, in terms of virtual memory, of a single reduce task
# launched by the Map-Reduce framework, used by the scheduler. A job can
# ask for multiple slots for a single reduce task via
# mapred.job.reduce.memory.mb, upto the limit specified by
# mapred.cluster.max.reduce.memory.mb, if the scheduler supports the
# feature. The value of -1 indicates that this feature is turned off.
default[:hadoop][:mapred][:mapred_cluster_max_reduce_memory_mb] = "-1"

# The size, in terms of virtual memory, of a single reduce slot in the
# Map-Reduce framework, used by the scheduler. A job can ask for multiple
# slots for a single reduce task via mapred.job.reduce.memory.mb, upto the
# limit specified by mapred.cluster.max.reduce.memory.mb, if the scheduler
# supports the feature. The value of -1 indicates that this feature is
# turned off.
default[:hadoop][:mapred][:mapred_cluster_reduce_memory_mb] = "-1"

# Should the outputs of the maps be compressed before being sent across the
# network. Uses SequenceFile compression.
default[:hadoop][:mapred][:mapred_compress_map_output] = "false"

# Frequency of the node health script to be run, in milliseconds.
default[:hadoop][:mapred][:mapred_healthChecker_interval] = "60000"

# List of arguments which are to be passed to node health script when it is
# being launched comma seperated.
default[:hadoop][:mapred][:mapred_healthChecker_script_args] = ""

# Absolute path to the script which is periodicallyrun by the node health
# monitoring service to determine if the node is healthy or not. If the
# value of this key is empty or the file does not exist in the location
# configured here, the node health monitoring service is not started.
default[:hadoop][:mapred][:mapred_healthChecker_script_path] = ""

# Time after node health script should be killed if unresponsive and
# considered that the script has failed.
default[:hadoop][:mapred][:mapred_healthChecker_script_timeout] = "600000"

# Expert: Approximate number of heart-beats that could arrive at JobTracker
# in a second. Assuming each RPC can be processed in 10msec, the default
# value is made 100 RPCs in a second.
default[:hadoop][:mapred][:mapred_heartbeats_in_second] = "100"

# Names a file that contains the list of nodes that may connect to the
# jobtracker. If the value is empty, all hosts are permitted.
default[:hadoop][:mapred][:mapred_hosts] = ""

# Names a file that contains the list of hosts that should be excluded by
# the jobtracker. If the value is empty, no hosts are excluded.
default[:hadoop][:mapred][:mapred_hosts_exclude] = ""

# The threshold, in terms of the number of files for the in-memory merge
# process. When we accumulate threshold number of files we initiate the
# in-memory merge and spill to disk. A value of 0 or less than 0 indicates
# we want to DON'T have any threshold and instead depend only on the
# ramfs's memory consumption to trigger the merge.
default[:hadoop][:mapred][:mapred_inmem_merge_threshold] = "1000"

# The size, in terms of virtual memory, of a single map task for the job. A
# job can ask for multiple slots for a single map task, rounded up to the
# next multiple of mapred.cluster.map.memory.mb and upto the limit
# specified by mapred.cluster.max.map.memory.mb, if the scheduler supports
# the feature. The value of -1 indicates that this feature is turned off
# iff mapred.cluster.map.memory.mb is also turned off (-1).
default[:hadoop][:mapred][:mapred_job_map_memory_mb] = "-1"

# Queue to which a job is submitted. This must match one of the queues
# defined in mapred.queue.names for the system. Also, the ACL setup for the
# queue must allow the current user to submit a job to the queue. Before
# specifying a queue, ensure that the system is configured with the queue,
# and access is allowed for submitting jobs to the queue.
default[:hadoop][:mapred][:mapred_job_queue_name] = "default"

# The percentage of memory- relative to the maximum heap size- to retain
# map outputs during the reduce. When the shuffle is concluded, any
# remaining map outputs in memory must consume less than this threshold
# before the reduce can begin.
default[:hadoop][:mapred][:mapred_job_reduce_input_buffer_percent] = "0.0"

# The size, in terms of virtual memory, of a single reduce task for the
# job. A job can ask for multiple slots for a single map task, rounded up
# to the next multiple of mapred.cluster.reduce.memory.mb and upto the
# limit specified by mapred.cluster.max.reduce.memory.mb, if the scheduler
# supports the feature. The value of -1 indicates that this feature is
# turned off iff mapred.cluster.reduce.memory.mb is also turned off (-1).
default[:hadoop][:mapred][:mapred_job_reduce_memory_mb] = "-1"

# How many tasks to run per jvm. If set to -1, there is no limit.
default[:hadoop][:mapred][:mapred_job_reuse_jvm_num_tasks] = "1"

# The percentage of memory to be allocated from the maximum heap size to
# storing map outputs during the shuffle.
default[:hadoop][:mapred][:mapred_job_shuffle_input_buffer_percent] = "0.70"

# The usage threshold at which an in-memory merge will be initiated,
# expressed as a percentage of the total memory allocated to storing
# in-memory map outputs, as defined by
# mapred.job.shuffle.input.buffer.percent.
default[:hadoop][:mapred][:mapred_job_shuffle_merge_percent] = "0.66"

# The host and port that the MapReduce job tracker runs at. If "local",
# then jobs are run in-process as a single map and reduce task.
default[:hadoop][:mapred][:mapred_job_tracker] = "local"

# The number of server threads for the JobTracker. This should be roughly
# 4% of the number of tasktracker nodes.
default[:hadoop][:mapred][:mapred_job_tracker_handler_count] = "10"

# The completed job history files are stored at this single well known
# location. If nothing is specified, the files are stored at
# ${hadoop.job.history.location}/done.
# DEFAULT: ${hadoop.job.history.location}/done
default[:hadoop][:mapred][:mapred_job_tracker_history_completed_location] = ""

# The job tracker http server address and port the server will listen on.
# If the port is 0 then the server will start on a free port.
default[:hadoop][:mapred][:mapred_job_tracker_http_address] = "0.0.0.0:50030"

# The number of job history files loaded in memory. The jobs are loaded
# when they are first accessed. The cache is cleared based on LRU.
default[:hadoop][:mapred][:mapred_job_tracker_jobhistory_lru_cache_size] = "5"

# Indicates if persistency of job status information is active or not.
default[:hadoop][:mapred][:mapred_job_tracker_persist_jobstatus_active] = "false"

# The directory where the job status information is persisted in a file
# system to be available after it drops of the memory queue and between
# jobtracker restarts.
default[:hadoop][:mapred][:mapred_job_tracker_persist_jobstatus_dir] = "/jobtracker/jobsInfo"

# The number of hours job status information is persisted in DFS. The job
# status information will be available after it drops of the memory queue
# and between jobtracker restarts. With a zero value the job status
# information is not persisted at all in DFS.
default[:hadoop][:mapred][:mapred_job_tracker_persist_jobstatus_hours] = ""

# The number of retired job status to keep in the cache.
default[:hadoop][:mapred][:mapred_job_tracker_retiredjobs_cache_size] = "1000"

# The width (in minutes) of each bucket in the tasktracker fault timeout
# window. Each bucket is reused in a circular manner after a full
# timeout-window interval (defined by
# mapred.jobtracker.blacklist.fault-timeout-window).
default[:hadoop][:mapred][:mapred_jobtracker_blacklist_fault_bucket_width] = "15"

# The timeout (in minutes) after which per-job tasktracker faults are
# forgiven. The window is logically a circular buffer of time-interval
# buckets whose width is defined by
# mapred.jobtracker.blacklist.fault-bucket-width; when the "now" pointer
# moves across a bucket boundary, the previous contents (faults) of the new
# bucket are cleared. In other words, the timeout's granularity is
# determined by the bucket width.
default[:hadoop][:mapred][:mapred_jobtracker_blacklist_fault_timeout_window] = "180"

# The maximum number of complete jobs per user to keep around before
# delegating them to the job history.
default[:hadoop][:mapred][:mapred_jobtracker_completeuserjobs_maximum] = "100"

# The block size of the job history file. Since the job recovery uses job
# history, its important to dump job history to disk as soon as possible.
# Note that this is an expert level parameter. The default value is set to
# 3 MB.
default[:hadoop][:mapred][:mapred_jobtracker_job_history_block_size] = "3145728"

# The maximum number of tasks for a single job. A value of -1 indicates
# that there is no maximum.
default[:hadoop][:mapred][:mapred_jobtracker_maxtasks_per_job] = "-1"

# "true" to enable (job) recovery upon restart, "false" to start afresh.
default[:hadoop][:mapred][:mapred_jobtracker_restart_recover] = "false"

# The class responsible for scheduling the tasks.
default[:hadoop][:mapred][:mapred_jobtracker_taskScheduler] = "org.apache.hadoop.mapred.JobQueueTaskScheduler"

# The maximum number of running tasks for a job before it gets preempted.
# No limits if undefined.
default[:hadoop][:mapred][:mapred_jobtracker_taskScheduler_maxRunningTasksPerJob] = ""

# Number of lines per split in NLineInputFormat.
default[:hadoop][:mapred][:mapred_line_input_format_linespermap] = "1"

# The local directory where MapReduce stores intermediate data files. May
# be a comma-separated list of directories on different devices in order to
# spread disk I/O. Directories that do not exist are ignored.
# DEFAULT: "${hadoop.tmp.dir}/mapred/local"  
default[:hadoop][:mapred][:mapred_local_dir] = [ "/var/lib/hadoop-0.20/cache/mapred/mapred/local" ]

# If the space in mapred.local.dir drops under this, do not ask more tasks
# until all the current ones have finished and cleaned up. Also, to save
# the rest of the tasks we have running, kill one of them, to clean up some
# space. Start with the reduce tasks, then go with the ones that have
# finished the least. Value in bytes.
default[:hadoop][:mapred][:mapred_local_dir_minspacekill] = ""

# If the space in mapred.local.dir drops under this, do not ask for more
# tasks. Value in bytes.
default[:hadoop][:mapred][:mapred_local_dir_minspacestart] = ""

# Expert: The maximum number of attempts per map task. In other words,
# framework will try to execute a map task these many number of times
# before giving up on it.
default[:hadoop][:mapred][:mapred_map_max_attempts] = "4"

# If the map outputs are compressed, how should they be compressed?.
default[:hadoop][:mapred][:mapred_map_output_compression_codec] = "org.apache.hadoop.io.compress.DefaultCodec"

# The default number of map tasks per job. Ignored when mapred.job.tracker
# is "local".
default[:hadoop][:mapred][:mapred_map_tasks] = "2"

# If true, then multiple instances of some map tasks may be executed in
# parallel.
default[:hadoop][:mapred][:mapred_map_tasks_speculative_execution] = "true"

# The number of blacklists for a tasktracker by various jobs after which
# the tasktracker will be marked as potentially faulty and is a candidate
# for graylisting across all jobs. (Unlike blacklisting, this is advisory;
# the tracker remains active. However, it is reported as graylisted in the
# web UI, with the expectation that chronically graylisted trackers will be
# manually decommissioned.) This value is tied to
# mapred.jobtracker.blacklist.fault-timeout-window; faults older than the
# window width are forgiven, so the tracker will recover from transient
# problems. It will also become healthy after a restart.
default[:hadoop][:mapred][:mapred_max_tracker_blacklists] = "4"

# The number of task-failures on a tasktracker of a given job after which
# new tasks of that job aren't assigned to it.
default[:hadoop][:mapred][:mapred_max_tracker_failures] = "4"

# The number of records to process during merge before sending a progress
# notification to the TaskTracker.
default[:hadoop][:mapred][:mapred_merge_recordsBeforeProgress] = "10000"

# The minimum size chunk that map input should be split into. Note that
# some file formats may have minimum split sizes that take priority over
# this setting.
default[:hadoop][:mapred][:mapred_min_split_size] = ""

# Should the job outputs be compressed?.
default[:hadoop][:mapred][:mapred_output_compress] = "false"

# If the job outputs are compressed, how should they be compressed?.
default[:hadoop][:mapred][:mapred_output_compression_codec] = "org.apache.hadoop.io.compress.DefaultCodec"

# If the job outputs are to compressed as SequenceFiles, how should they be
# compressed? Should be one of NONE, RECORD or BLOCK.
default[:hadoop][:mapred][:mapred_output_compression_type] = "RECORD"

# This values defines the state , default queue is in. the values can be
# either "STOPPED" or "RUNNING" This value can be changed at runtime.
default[:hadoop][:mapred][:mapred_queue_default_state] = "RUNNING"

# Comma separated list of queues configured for this jobtracker. Jobs are
# added to queues and schedulers can configure different scheduling
# properties for the various queues. To configure a property for a queue,
# the name of the queue must match the name specified in this value. Queue
# properties that are common to all schedulers are configured here with the
# naming convention, mapred.queue.$QUEUE-NAME.$PROPERTY-NAME, for e.g.
# mapred.queue.default.submit-job-acl. The number of queues configured in
# this parameter could depend on the type of scheduler being used, as
# specified in mapred.jobtracker.taskScheduler. For example, the
# JobQueueTaskScheduler supports only a single queue, which is the default
# configured here. Before adding more queues, ensure that the scheduler
# you've configured supports multiple queues.
default[:hadoop][:mapred][:mapred_queue_names] = "default"

# The maximum amount of time (in seconds) a reducer spends on fetching one
# map output before declaring it as failed.
default[:hadoop][:mapred][:mapred_reduce_copy_backoff] = "300"

# Expert: The maximum number of attempts per reduce task. In other words,
# framework will try to execute a reduce task these many number of times
# before giving up on it.
default[:hadoop][:mapred][:mapred_reduce_max_attempts] = "4"

# The default number of parallel transfers run by reduce during the
# copy(shuffle) phase.
default[:hadoop][:mapred][:mapred_reduce_parallel_copies] = "5"

# Fraction of the number of maps in the job which should be complete before
# reduces are scheduled for the job.
default[:hadoop][:mapred][:mapred_reduce_slowstart_completed_maps] = "0.05"

# The default number of reduce tasks per job. Typically set to 99% of the
# cluster's reduce capacity, so that if a node fails the reduces can still
# be executed in a single wave. Ignored when mapred.job.tracker is "local".
default[:hadoop][:mapred][:mapred_reduce_tasks] = "1"

# If true, then multiple instances of some reduce tasks may be executed in
# parallel.
default[:hadoop][:mapred][:mapred_reduce_tasks_speculative_execution] = "true"

# The number of Task attempts AFTER which skip mode will be kicked off.
# When skip mode is kicked off, the tasks reports the range of records
# which it will process next, to the TaskTracker. So that on failures, TT
# knows which ones are possibly the bad records. On further executions,
# those are skipped.
default[:hadoop][:mapred][:mapred_skip_attempts_to_start_skipping] = "2"

# The flag which if set to true,
# SkipBadRecords.COUNTER_MAP_PROCESSED_RECORDS is incremented by MapRunner
# after invoking the map function. This value must be set to false for
# applications which process the records asynchronously or buffer the input
# records. For example streaming. In such cases applications should
# increment this counter on their own.
default[:hadoop][:mapred][:mapred_skip_map_auto_incr_proc_count] = "true"

# The number of acceptable skip records surrounding the bad record PER bad
# record in mapper. The number includes the bad record as well. To turn the
# feature of detection/skipping of bad records off, set the value to 0. The
# framework tries to narrow down the skipped range by retrying until this
# threshold is met OR all attempts get exhausted for this task. Set the
# value to Long.MAX_VALUE to indicate that framework need not try to narrow
# down. Whatever records(depends on application) get skipped are
# acceptable.
default[:hadoop][:mapred][:mapred_skip_map_max_skip_records] = ""

# If no value is specified here, the skipped records are written to the
# output directory at _logs/skip. User can stop writing skipped records by
# giving the value "none".
default[:hadoop][:mapred][:mapred_skip_out_dir] = ""

# The flag which if set to true,
# SkipBadRecords.COUNTER_REDUCE_PROCESSED_GROUPS is incremented by
# framework after invoking the reduce function. This value must be set to
# false for applications which process the records asynchronously or buffer
# the input records. For example streaming. In such cases applications
# should increment this counter on their own.
default[:hadoop][:mapred][:mapred_skip_reduce_auto_incr_proc_count] = "true"

# The number of acceptable skip groups surrounding the bad group PER bad
# group in reducer. The number includes the bad group as well. To turn the
# feature of detection/skipping of bad groups off, set the value to 0. The
# framework tries to narrow down the skipped range by retrying until this
# threshold is met OR all attempts get exhausted for this task. Set the
# value to Long.MAX_VALUE to indicate that framework need not try to narrow
# down. Whatever groups(depends on application) get skipped are acceptable.
default[:hadoop][:mapred][:mapred_skip_reduce_max_skip_groups] = ""

# The replication level for submitted job files. This should be around the
# square root of the number of nodes.
default[:hadoop][:mapred][:mapred_submit_replication] = "10"

# The directory where MapReduce stores control files (/mapred/system).
default[:hadoop][:mapred][:mapred_system_dir] = "/mapred/system"

# This is the max level of the task cache. For example, if the level is 2,
# the tasks cached are at the host level and at the rack level.
default[:hadoop][:mapred][:mapred_task_cache_levels] = "2"

# To set whether the system should collect profiler information for some of
# the tasks in this job? The information is stored in the user log
# directory. The value is "true" if task profiling is enabled.
default[:hadoop][:mapred][:mapred_task_profile] = "false"

# To set the ranges of map tasks to profile. mapred.task.profile has to be
# set to true for the value to be accounted.
default[:hadoop][:mapred][:mapred_task_profile_maps] = "0-2"

# To set the ranges of reduce tasks to profile. mapred.task.profile has to
# be set to true for the value to be accounted.
default[:hadoop][:mapred][:mapred_task_profile_reduces] = "0-2"

# The number of milliseconds before a task will be terminated if it neither
# reads an input, writes an output, nor updates its status string.
default[:hadoop][:mapred][:mapred_task_timeout] = "600000"

# The task tracker http server address and port. If the port is 0 then the
# server will start on a free port.
default[:hadoop][:mapred][:mapred_task_tracker_http_address] = "0.0.0.0:50060"

# The interface and port that task tracker server listens on. Since it is
# only connected to by the tasks, it uses the local interface. EXPERT ONLY.
# Should only be changed if your host does not have the loopback interface.
default[:hadoop][:mapred][:mapred_task_tracker_report_address] = "127.0.0.1:0"

# TaskController which is used to launch and manage task execution.
default[:hadoop][:mapred][:mapred_task_tracker_task_controller] = "org.apache.hadoop.mapred.DefaultTaskController"

# The name of the Network Interface from which a task tracker should report
# its IP address.
default[:hadoop][:mapred][:mapred_tasktracker_dns_interface] = "default"

# The host name or IP address of the name server (DNS) which a TaskTracker
# should use to determine the host name used by the JobTracker for
# communication and display purposes.
default[:hadoop][:mapred][:mapred_tasktracker_dns_nameserver] = "default"

# Expert: The time-interval, in miliseconds, after which a tasktracker is
# declared 'lost' if it doesn't send heartbeats.
default[:hadoop][:mapred][:mapred_tasktracker_expiry_interval] = "600000"

# The maximum memory that a task tracker allows for the index cache that is
# used when serving map outputs to reducers.
default[:hadoop][:mapred][:mapred_tasktracker_indexcache_mb] = "10"

# The maximum number of map tasks that will be run simultaneously by a task
# tracker.
default[:hadoop][:mapred][:mapred_tasktracker_map_tasks_maximum] = "2"

# Name of the class whose instance will be used to query memory information
# on the tasktracker. The class must be an instance of
# org.apache.hadoop.util.MemoryCalculatorPlugin. If the value is null, the
# tasktracker attempts to use a class appropriate to the platform.
# Currently, the only platform supported is Linux.
default[:hadoop][:mapred][:mapred_tasktracker_memory_calculator_plugin] = ""

# The maximum number of reduce tasks that will be run simultaneously by a
# task tracker.
default[:hadoop][:mapred][:mapred_tasktracker_reduce_tasks_maximum] = "2"

# The interval, in milliseconds, for which the tasktracker waits between
# two cycles of monitoring its tasks' memory usage. Used only if tasks'
# memory management is enabled via mapred.tasktracker.tasks.maxmemory.
default[:hadoop][:mapred][:mapred_tasktracker_taskmemorymanager_monitoring_interval] = "5000"

# The time, in milliseconds, the tasktracker waits for sending a SIGKILL to
# a process, after it has been sent a SIGTERM.
default[:hadoop][:mapred][:mapred_tasktracker_tasks_sleeptime_before_sigkill] = "5000"

# A shared directory for temporary files.
# DEFAULT : ${hadoop.tmp.dir}/mapred/temp
default[:hadoop][:mapred][:mapred_temp_dir] = "/mnt/hdfs/hdfs01/data1/mapred/temp"

# The maximum allowed size of the user jobconf. The default is set to 5 MB.
default[:hadoop][:mapred][:mapred_user_jobconf_limit] = "5242880"

# The maximum size of user-logs of each task in KB. 0 disables the cap.
default[:hadoop][:mapred][:mapred_userlog_limit_kb] = ""

# The maximum time, in hours, for which the user-logs are to be retained
# after the job completion.
default[:hadoop][:mapred][:mapred_userlog_retain_hours] = "24"

# Job specific access-control list for 'modifying' the job. It is only used
# if authorization is enabled in Map/Reduce by setting the configuration
# property mapred.acls.enabled to true. This specifies the list of users
# and/or groups who can do modification operations on the job. For
# specifying a list of users and groups the format to use is "user1,user2
# group1,group". If set to '*', it allows all users/groups to modify this
# job. If set to ' '(i.e. space), it allows none. This configuration is
# used to guard all the modifications with respect to this job and takes
# care of all the following operations: o killing this job o killing a task
# of this job, failing a task of this job o setting the priority of this
# job Each of these operations are also protected by the per-queue level
# ACL "acl-administer-jobs" configured via mapred-queues.xml. So a caller
# should have the authorization to satisfy either the queue-level ACL or
# the job-level ACL. Irrespective of this ACL configuration, job-owner, the
# user who started the cluster, cluster administrators configured via
# mapreduce.cluster.administrators and queue administrators of the queue to
# which this job is submitted to configured via
# mapred.queue.queue-name.acl-administer-jobs in mapred-queue-acls.xml can
# do all the modification operations on a job. By default, nobody else
# besides job-owner, the user who started the cluster, cluster
# administrators and queue administrators can perform modification
# operations on a job.
default[:hadoop][:mapred][:mapreduce_job_acl_modify_job] = ""

# Job specific access-control list for 'viewing' the job. It is only used
# if authorization is enabled in Map/Reduce by setting the configuration
# property mapred.acls.enabled to true. This specifies the list of users
# and/or groups who can view private details about the job. For specifying
# a list of users and groups the format to use is "user1,user2
# group1,group". If set to '*', it allows all users/groups to modify this
# job. If set to ' '(i.e. space), it allows none. This configuration is
# used to guard some of the job-views and at present only protects APIs
# that can return possibly sensitive information of the job-owner like o
# job-level counters o task-level counters o tasks' diagnostic information
# o task-logs displayed on the TaskTracker web-UI and o job.xml showed by
# the JobTracker's web-UI Every other piece of information of jobs is still
# accessible by any other user, for e.g., JobStatus, JobProfile, list of
# jobs in the queue, etc. Irrespective of this ACL configuration,
# job-owner, the user who started the cluster, cluster administrators
# configured via mapreduce.cluster.administrators and queue administrators
# of the queue to which this job is submitted to configured via
# mapred.queue.queue-name.acl-administer-jobs in mapred-queue-acls.xml can
# do all the view operations on a job. By default, nobody else besides
# job-owner, the user who started the cluster, cluster administrators and
# queue administrators can perform view operations on a job.
default[:hadoop][:mapred][:mapreduce_job_acl_view_job] = ""

# if false - do not unregister/cancel delegation tokens from renewal,
# because same tokens may be used by spawned jobs.
default[:hadoop][:mapred][:mapreduce_job_complete_cancel_delegation_tokens] = "true"

# Limit on the number of counters allowed per job.
default[:hadoop][:mapred][:mapreduce_job_counters_limit] = "120"

# The maximum permissible size of the split metainfo file. The JobTracker
# won't attempt to read split metainfo files bigger than the configured
# value. No limits if set to -1.
default[:hadoop][:mapred][:mapreduce_job_split_metainfo_maxsize] = "10000000"

# The root of the staging area for users' job files In practice, this
# should be the directory where users' home directories are located
# (usually /user).
# DEFAULT: ${hadoop.tmp.dir}/mapred/staging
default[:hadoop][:mapred][:mapreduce_jobtracker_staging_root_dir] = "/mnt/hdfs/hdfs01/data1/mapred/staging"

# The limit on the input size of the reduce. If the estimated input size of
# the reduce is greater than this value, job is failed. A value of -1 means
# that there is no limit set.
default[:hadoop][:mapred][:mapreduce_reduce_input_limit] = "-1"

# Expert: The maximum amount of time (in milli seconds) a reduce task
# spends in trying to connect to a tasktracker for getting map output.
default[:hadoop][:mapred][:mapreduce_reduce_shuffle_connect_timeout] = "180000"

# Expert: The maximum amount of time (in milli seconds) a reduce task waits
# for map output data to be available for reading after obtaining
# connection.
default[:hadoop][:mapred][:mapreduce_reduce_shuffle_read_timeout] = "180000"

# Expert: Group to which TaskTracker belongs. If LinuxTaskController is
# configured via mapreduce.tasktracker.taskcontroller, the group owner of
# the task-controller binary should be same as this group.
default[:hadoop][:mapred][:mapreduce_tasktracker_group] = ""

# Expert: Set this to true to let the tasktracker send an out-of-band
# heartbeat on task-completion for better latency.
default[:hadoop][:mapred][:mapreduce_tasktracker_outofband_heartbeat] = "false"

# The number of worker threads that for the http server. This is used for
# map output fetching.
default[:hadoop][:mapred][:tasktracker_http_threads] = "40"
