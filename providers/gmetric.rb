

action :enable do

  template "/usr/local/bin/#{new_resource.script_name}-ganglia" do
    source "ganglia/#{new_resource.script_name}.gmetric.erb"
    owner "root"
    group "root"
    mode "755"
    variables :options => new_resource.options
  end

  cron "#{new_resource.script_name}-ganglia" do
    minute new_resource.minute
    hour new_resource.hour
    day new_resource.day
    month new_resource.month 
    weekday new_resource.weekday
    command "/usr/local/bin/#{new_resource.script_name}-ganglia"
  end

end

action :disable do

  file "/usr/local/bin/#{new_resource.script_name}-ganglia" do
    action :delete
  end

  cron "#{new_resource.script_name}-ganglia" do
    action :delete
  end

end
