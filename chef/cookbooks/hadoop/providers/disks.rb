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

=begin
require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def parse_results(input)
  Chef::Log.debug("read:" + input.inspect)
  input = input.to_a
  part_tab = []  
  catch (:parse_error) do
    input.each { |line|
  Chef::Log.info("read:" + input.inspect) if debug
  }
  end
end

def get_disks()
  Chef::Log.debug("reading disks") if debug
  pipe= IO.popen("fdisk -l")
  result = pipe.readlines
  parse_results result  
end
=end
