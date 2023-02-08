#
# Cookbook Name:: cookbook_db_refresh
# Recipe:: default
#
# Copyright 2017, Oracle
#
# All rights reserved - Do Not Redistribute
# Author : Sagar Fale
=begin
include_recipe "cookbook_db_refresh::getpwd-checks"
include_recipe "cookbook_db_refresh::tns-listener-checks"
include_recipe "cookbook_db_refresh::asm-checks"
include_recipe "cookbook_db_refresh::ssh-checks"
include_recipe "cookbook_db_refresh::check-shared-folder-czd"
include_recipe "cookbook_db_refresh::db-pre-refresh-export"
include_recipe "cookbook_db_refresh::sourceDB-files-copy"
=end
=begin
include_recipe "cookbook_db_refresh::getpwd-checks"
include_recipe "cookbook_db_refresh::tns-listener-checks"
include_recipe "cookbook_db_refresh::asm-checks"
include_recipe "cookbook_db_refresh::ssh-checks"
include_recipe "cookbook_db_refresh::check-shared-folder-czd"
include_recipe "cookbook_db_refresh::db-pre-refresh-export"
include_recipe "cookbook_db_refresh::sourceDB-files-copy"
#include_recipe "cookbook_db_refresh::rman-clone"
=end

if(File.exist?("#{node[:db][:rdbms][:script_home]}" + "/" + "#{node[:db][:rdbms][:db_name]}" + "/" + "refresh_first_run_" + "#{node[:db][:rdbms][:db_name]}" + ".lock"))
    include_recipe "cookbook_db_refresh::start_db_refresh_after_failure"
    include_recipe "cookbook_db_refresh::rman-restore-status"
	include_recipe "cookbook_db_refresh::rac-conversion"
	include_recipe "cookbook_db_refresh::customised-sql-czd"
	#include_recipe "cookbook_db_refresh::db-post-refresh-import"
	include_recipe "cookbook_db_refresh::rman-resync"
else 
	include_recipe "cookbook_db_refresh::getpwd-checks"
	include_recipe "cookbook_db_refresh::tns-listener-checks"
	include_recipe "cookbook_db_refresh::asm-checks"
	#include_recipe "cookbook_db_refresh::ssh-checks"
	include_recipe "cookbook_db_refresh::check-shared-folder-czd"
	#include_recipe "cookbook_db_refresh::db-pre-refresh-export"
	#include_recipe "cookbook_db_refresh::sourceDB-files-copy"
    include_recipe "cookbook_db_refresh::rman-clone"
    include_recipe "cookbook_db_refresh::rman-restore-status"
	include_recipe "cookbook_db_refresh::rac-conversion"
	include_recipe "cookbook_db_refresh::customised-sql-czd"
	#include_recipe "cookbook_db_refresh::db-post-refresh-import"
	include_recipe "cookbook_db_refresh::rman-resync"
end
=begin
include_recipe "cookbook_db_refresh::rman-restore-status"
include_recipe "cookbook_db_refresh::rac-conversion"
include_recipe "cookbook_db_refresh::customised-sql-czd"
include_recipe "cookbook_db_refresh::db-post-refresh-import"
#include_recipe "cookbook_db_refresh::rman-resync"
=end
