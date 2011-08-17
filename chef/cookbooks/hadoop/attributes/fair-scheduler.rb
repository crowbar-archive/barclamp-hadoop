#
# Cookbook Name: hadoop
# Attributes: fair-scheduler.rb
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
# Fair scheduler configuration parameters (/etc/hadoop/conf/fair-scheduler-site.xml).
#######################################################################

#######################################################################
# Common settings.
#######################################################################

# Sets the default minimum share preemption timeout for any pools where it
# is not specified.
default[:hadoop][:scheduler][:default_min_share_preemption_timeout] = "600"

# Sets the default scheduling mode (fair or fifo) for pools whose mode is
# not specified.
default[:hadoop][:scheduler][:default_pool_scheduling_mode] = "fair"

# Sets the preemption timeout used when jobs are below half their fair
# share.
default[:hadoop][:scheduler][:fair_share_preemption_timeout] = "600"

# Sets the default running job limit for any pools whose limit is not
# specified.
default[:hadoop][:scheduler][:pool_max_jobs_default] = "20"

# Sets the default running job limit for any users whose limit is not
# specified.
default[:hadoop][:scheduler][:user_max_jobs_default] = "10"

#######################################################################
# Production pool specific settings.
#######################################################################

default[:hadoop][:scheduler][:production][:min_maps] = "32"
default[:hadoop][:scheduler][:production][:min_reduces] = "15"
default[:hadoop][:scheduler][:production][:min_share_preemption_timeout] = "60"
default[:hadoop][:scheduler][:production][:scheduling_mode] = "fair"
default[:hadoop][:scheduler][:production][:weight] = "2.0"
