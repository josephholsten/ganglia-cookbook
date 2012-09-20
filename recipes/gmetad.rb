case node['platform']
when "ubuntu", "debian"
  package "gmetad"
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"
  execute "copy gmetad init script" do
    command "cp " +
      "/usr/src/ganglia-#{node['ganglia']['version']}/gmetad/gmetad.init " +
      "/etc/init.d/gmetad"
    not_if "test -f /etc/init.d/gmetad"
  end
end

directory "/var/lib/ganglia/rrds" do
  owner "nobody"
  recursive true
end

hosts = if Chef::Config[:solo]
  ['localhost']
elsif node['ganglia']['unicast']
  ['localhost']
else
  search(:node, "*:*").map {|node| node['ipaddress']}
end

if node['recipes'].include? "iptables"
  include_recipe "ganglia::iptables"
end

template "/etc/ganglia/gmetad.conf" do
  source "gmetad.conf.erb"
  variables( :hosts => hosts.join(" "),
             :cluster_name => node['ganglia']['cluster_name'])
  notifies :restart, "service[gmetad]"
end

service "gmetad" do
  supports :restart => true
  action [ :enable, :start ]
end
