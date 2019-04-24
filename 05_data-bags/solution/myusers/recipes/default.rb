#
# Cookbook:: myusers
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

include_recipe 'myusers::users'

## if you've created a groups data bag, you can include the recipe here. This groups recipe will only run on centos.

# if node['platform'] == 'centos'
#   include_recipe 'myusers::groups'
# end