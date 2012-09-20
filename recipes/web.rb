sysadmins = if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
  []
else
  search(:users, 'groups:sysadmin')
end

if node['public_domain']
  case node.chef_environment
  when "production"
    public_domain = node['public_domain']
  else
    public_domain = "#{node.chef_environment}.#{node['public_domain']}"
  end
else
  public_domain = node['domain']
end

case node['platform']
when "ubuntu", "debian"
  package "ganglia-webfrontend"
when "redhat", "centos", "fedora"
  package "httpd"
  package "php"
  include_recipe "ganglia::source"
  include_recipe "ganglia::gmetad"

  execute "copy web directory" do
    command "cp -r web /var/www/html/ganglia"
    creates "/var/www/html/ganglia"
    cwd "/usr/src/ganglia-#{node['ganglia']['version']}"
  end
end

directory node['ganglia']['conf_dir']
directory node['ganglia']['log_dir']

case node['ganglia']['server_auth_method']
when "openid"
  include_recipe "apache2::mod_auth_openid"
else
  template "#{node['ganglia']['conf_dir']}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner node['ganglia']['user']
    group node['apache']['user']
    mode 0640
    variables(
      :sysadmins => sysadmins
    )
  end
end

template "#{node['apache']['dir']}/sites-available/ganglia.conf" do
  source "httpd_vhost.conf.erb"
  mode 0644
  variables :public_domain => public_domain
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/ganglia.conf")
    notifies :reload, "service[apache2]"
  end
end

apache_site "ganglia.conf"
