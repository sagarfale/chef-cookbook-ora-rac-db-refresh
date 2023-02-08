# Cookbook Name:: cookbook_db_refresh
# Recipe :: tns-listener-checks
# Copyright 2017, Oracle
# All rights reserved - Do Not Redistribute
# Author : Sagar Fale

bash 'tns-listener-checks' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
			echo "*** Checking tnsping and lsnrctl on host ${rac_node1}..."
			echo -e "\e[97m"
			if [ ! -x ${ORACLE_HOME}/bin/tnsping ]
			then
			        echo 
			        echo "\t\"ORACLE_HOME/bin/tnsping\" not found; aborting..."
			        echo
			        exit 1
			fi
			#
			if [ ! -x ${ORACLE_HOME}/bin/lsnrctl ]
			then
			        echo 
			        echo "\t\"ORACLE_HOME/bin/lsnrctl\" not found; aborting..."
			        echo
			        exit 1
			fi	
			$ORA_CRS_HOME/bin/lsnrctl services LISTENER_${db_name}_REFRESH | tail -6
			echo ""
			EOH

end

bash 'checking-listener-entry' do
		user 'oracle'
		group 'oinstall'
		environment (node[:db][:rdbms][:env_12c])
		code <<-EOH
		echo -e "\e[33m*** Checking listener entry..."
		echo -e "\e[97m"
		cd $ORA_CRS_HOME/network/admin
		bkp_temp=`date +%d-%b-%Y-%H-%M-%S`
  		cp listener.ora listener.ora_bkp_${bkp_temp}
		grep -i LISTENER_${db_name}_REFRESH listener.ora
		if [ $? -eq 0 ];
			then
  			 	echo -e "\e[32m*** Listener entry LISTENER_${db_name}_REFRESH may be present...  "
			else 
				echo -e "\e[97m "
  				echo "LISTENER_${db_name}_REFRESH = (DESCRIPTION_LIST = (DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = ${target_db_host}.us.oracle.com)(PORT = ${target_db_refresh_port})))))" >> listener.ora
  				echo "SID_LIST_LISTENER_${db_name}_REFRESH = (SID_LIST = (SID_DESC = (SDU = 32768)(TDU = 32767) (GLOBAL_DBNAME = ${db_name}.us.oracle.com)(SID_NAME = ${ORACLE_SID})(ORACLE_HOME = ${ORACLE_HOME})(ENVS = "TNS_ADMIN=${ORACLE_HOME}/network/admin ,DB_NAME=${db_name}")))" >> listener.ora
		fi
		EOH
end


bash 'refresh-listener-startup-if-required' do 
	user 'oracle'
	group 'oinstall'
	environment (node['grid']['crs-asm']['asm_env_12c'])
	code <<-EOH
		echo -e "\e[33m*** Checking listener..."
		echo -e "\e[97m"
		$ORACLE_HOME/bin/lsnrctl status LISTENER_${db_name}_REFRESH
		if [ $? -eq 0 ];
			then
  			 	echo -e "\e[32m*** able to ping ${db_name}_refresh...  verified Successfully"
			else 
				cd $TNS_ADMIN
  				echo -e "\e[31m*** LISTENER_${db_name}_REFRESH may NOT present.. Pl check" >&2
  				echo -e "\e[97m "
  				$ORACLE_HOME/bin/lsnrctl start LISTENER_${db_name}_REFRESH | tail -6
  				$ORACLE_HOME/bin/lsnrctl status LISTENER_${db_name}_REFRESH | tail -6
			fi
		EOH
end

bash 'refresh-tns-entry-addition-if-required' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
		echo -e "\e[33m*** Checking tnsping..."
		echo -ne "\e[97m"
		$ORACLE_HOME/bin/tnsping ${ORACLE_SID}_refresh
		if [ $? -eq 0 ];
			then
  			 	echo -e "\e[32m*** able to ping ${ORACLE_SID}_refresh...  verified Successfully"
			else 
  				echo -e "\e[31m >>> TNS Entry may not be present may NOT present.. Pl check" >&2
  				echo -e "\e[97m"
  				cd $ORA_CRS_HOME/network/admin
  				bkp_temp=`date +%d-%b-%Y-%H-%M-%S`
  				cp tnsnames.ora  tnsnames.ora_bkp_${bkp_temp}
  				echo -e "\e[97m"
  				echo "${ORACLE_SID}_REFRESH,${ORACLE_SID}_REFRESH.US.ORACLE.COM = (DESCRIPTION = (SDU = 32768)(ADDRESS = (PROTOCOL = tcp)(host = ${target_db_host}.us.oracle.com)(port = ${target_db_refresh_port}))(CONNECT_DATA = (SERVICE_NAME = ${db_name}.us.oracle.com)(INSTANCE_NAME = ${ORACLE_SID})))" >> tnsnames.ora 
  				$ORACLE_HOME/bin/tnsping ${ORACLE_SID}_refresh | tail -4
			fi
		EOH
end
