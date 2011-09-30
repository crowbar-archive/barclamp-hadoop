#
# Cookbook Name: hadoop
# Attributes: common.rb
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

debug = true

###################################################################
# make_dir_path(path, owner, group, mode)
# Create a directory structure and set ownership/permissions. 
# NOTE: "directory recursive" does not set the parent directory
# permissions correctly for hadoop. All directories (and the parent)
# needs to have the owner/group set and directory recursive does
# not apparently do this.  
###################################################################

def make_dir_path(path, owner, group, mode)
  Chef::Log.info("make_dir_path") if @debug
  dir = ""
  path.split('/').each do |d|
    next if (d.nil? || d.empty?)
    dir = "#{dir}/#{d}"
    Chef::Log.info("mkdir #{dir}") if @debug
    directory dir do
      owner owner
      group group
      mode mode
      action :create
    end
  end
end

###################################################################
# make_dir_array(path_array, owner, group, mode)
# Same as above but use an array of directory paths.
###################################################################

def make_dir_array(array, owner, group, mode)
  Chef::Log.info("make_dir_array") if @debug
  array.each do |path|
    make_dir_path(path, owner, group, mode)
  end
end
