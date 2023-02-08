### Cookbook : cookbook_db_refresh
### Recipe : rman-resync
### Author : Sagar Fale
### Version : 0.1
bash 'rman-reregister-db' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
		echo -e "\e[33m***  Rman-reregister-db..."
		echo -e "\e[97m"
		$ORACLE_HOME/bin/rman target / catalog rman_${db_name}/${db_name}rman@rmanap  <<-EOK
		register database;
		EOK
		$ORACLE_HOME/bin/rman target / catalog rman_${db_name}/${db_name}rman@rmanup  <<-EOF
		register database;
		EOF
		EOH
end