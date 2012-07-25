# Copyright 2012, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
class HadoopNavs < ActiveRecord::Migration
  def self.up
    
    Nav.find_or_create_by_item :item=>'hadoop_barclamps', :parent_item=>'barclamps', :name=>'nav.hadoop', :description=>'nav.hadoop_description', :path=>"index_barclamp_path(:controller=>'hadoop')", :order=>500
    Nav.find_or_create_by_item :item=>'hadoop_ug', :parent_item=>'help', :name=>'nav.hadoop_ug', :description=>'nav.hadoop_ug_description', :path=>'\'"/hadoop_users_guide.pdf", { :link => { :target => "_blank" } }\'', :order=>600

  end

  def self.down
    Nav.delete_by_item 'hadoop_barclamps'
    Nav.delete_by_item 'hadoop_ug'
  end
end
