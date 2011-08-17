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

#######################################################################
# Crowbar barclamp configuration parameters.
#######################################################################

# Crowbar barclamp config block
default[:hadoop][:config] = {}
default[:hadoop][:config][:environment] = "hadoop-config-default"
default[:hadoop][:debug] = true

# Hadoop package versions   
default[:hadoop][:packages][:core][:version] = "0.20.2+923.21-1"
default[:hadoop][:packages][:hive][:version] = "0.7.0+11-2"
default[:hadoop][:packages][:flume][:version] = "0.9.3+15.3-1"
default[:hadoop][:packages][:hbase][:version] = "0.90.1+15.18-1"


