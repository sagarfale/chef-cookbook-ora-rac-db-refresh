### cookbook : cookbook_db_refresh
### Recipe : customised-sql-czd
### Author : Sagar Fale
### Version : 0.1
bash 'customised-sql-czd' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
		echo -e "\e[33m*** Updating applications_system_name ..."
		echo -e "\e[97m"
		$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF
		set feedback off
		update applsys.fnd_product_groups set applications_system_name = '${db_name}';
		commit;
		set head off
		set pages 200
		select 'applications_system_name ==> '  as APPLICATIONS_SYSTEM_NAME,APPLICATIONS_SYSTEM_NAME from  applsys.fnd_product_groups;
		EOF
		echo "";
	EOH
end