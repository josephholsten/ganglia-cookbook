directory "/etc/ganglia-webfrontend"

case node['platform_family']
when "debian"
  package "ganglia-webfrontend"

  link "/etc/apache2/sites-enabled/ganglia" do
    to "/etc/ganglia-webfrontend/apache.conf"
    notifies :restart, "service[apache2]"
  end

when "rhel", "fedora"
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

service "apache2" do
  service_name "httpd" if platform_family?( "rhel", "fedora" )
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
