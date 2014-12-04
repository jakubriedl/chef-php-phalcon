#
# Cookbook Name:: php-phalcon
# Recipe:: default
#
# Copyright 2014, kinzal
node['php-phalcon']['packages'].each do |phalcon_package|
  package phalcon_package do
  	action :install
  end
end

path  = "#{Chef::Config['file_cache_path']}/phalcon"

directory path do
    recursive true
    action :delete
end

git path do
	repository node['php-phalcon']['git_url']
	reference node['php-phalcon']['git_ref']
	action :sync
end

execute  "phalcon-build" do
	cwd "#{path}/build"
	user "root"
	command %{./install}

    node['php']['conf_dirs'].each do |conf_dir|
        not_if do
            ::File.exists?("#{conf_dir}/#{node['php-phalcon']['conf_file']}")
        end
    end
end

node['php']['conf_dirs'].each do |conf_dir|
    template "#{conf_dir}/#{node['php-phalcon']['conf_file']}" do
        source "phalcon.ini.erb"
        owner "root"
        group "root"
        mode 0644
    end
end

if node['php-phalcon']['devtools']
    bash "phalcon-devtools" do
        user "root"
        cwd "/usr/share"
        code <<-EOH
        	rm -rf phalcon-devtools /usr/bin/phalcon
            git clone https://github.com/bileto/phalcon-devtools.git
            cd phalcon-devtools
            . ./phalcon.sh
			ln -s /usr/share/phalcon-devtools/phalcon.php /usr/bin/phalcon
        EOH
    end
end