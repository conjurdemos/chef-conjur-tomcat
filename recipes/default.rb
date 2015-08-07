#
# Cookbook Name:: chef-conjur-tomcat
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'build-essential'
include_recipe 'conjur-host-identity'
include_recipe 'conjur'
