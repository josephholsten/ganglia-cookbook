#
# Cookbook Name:: ganglia
# Recipe:: default
#
# Copyright 2011, Heavy Water Software Inc.
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

case node['platform']
when "ubuntu", "debian"
  package "ganglia-monitor"
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"

  execute "copy ganglia-monitor init script" do
    command "cp " +
      "/usr/src/ganglia-#{node['ganglia']['version']}/gmond/gmond.init " +
      "/etc/init.d/ganglia-monitor"
    not_if "test -f /etc/init.d/ganglia-monitor"
  end

  user "ganglia"
end

directory "/etc/ganglia"

mon_hosts = [ "127.0.0.1" ]
case node['ganglia']['unicast']
when true
  Chef::Log.info("Connecting to ganglia in unicast mode")
  if node.run_list.roles.include?(node['ganglia']['server_role'])
    mon_hosts << node['ipaddress']
  elsif Chef::Config[:solo]
    Chef::Log.warn("#{cookbook_name}::#{recipe_name} is intended for use with Chef Server, defaulting to 127.0.0.1 for ganglia host.")
  elsif node['ganglia']['multi_environment_monitoring']
    search(:node, "role:#{node['ganglia']['server_role']}") do |n|
      mon_hosts << n['ipaddress']
    end
  else
    search(:node, "role:#{node['ganglia']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
      mon_hosts << n['ipaddress']
    end
  end
  templ = "gmond_unicast.conf.erb"
when false
  Chef::Log.info("Connecting to ganglia in multicast mode")
  templ = "gmond.conf.erb"
end

template "/etc/ganglia/gmond.conf" do
  source templ
  variables( :cluster_name => node['ganglia']['cluster_name'],
             :host => mon_hosts.last )
  notifies :restart, "service[ganglia-monitor]"
end

service "ganglia-monitor" do
  pattern "gmond"
  supports :restart => true
  action [ :enable, :start ]
end
