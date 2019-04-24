#
# Cookbook:: apache
# Recipe:: server
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package 'httpd'

template '/var/www/html/index.html' do
  source 'index.html.erb'
end

service 'httpd' do
  action [:enable, :start]
end