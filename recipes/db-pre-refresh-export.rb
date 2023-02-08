### cookbook : cookbook_db_refresh
### Recipe : db-pre-refresh-export
### Author : Sagar Fale
### Version : 0.1
=begin 
bash 'DV_Disable' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
		echo -e "\e[33m*** Disabling the Data Vault"
		echo -e "\e[97m"
		mkdir -p ${script_home}/${db_name}
		#getpwd -e ${source_db_name} dbvowner > ${script_home}/${db_name}/getpwd_${db_name}_pwd.log
		#dv_prod_pwd=`getpwd -e ${source_db_name} dbvowner`
		#grep -i invalid ${script_home}/${db_name}/getpwd_${db_name}_pwd.log
		echo 
		if [ $? -eq 0 ]
			then
				#dv_prod_pwd=`getpwd -e ${source_db_name} dbvowner`
				$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOP
				alter user dbvowner identified  by 123456;
				EOP
				dv_prod_pwd=123456
				echo -e "\e[97m*** Disabling Data vault...."
				$ORACLE_HOME/bin/sqlplus -s dbvowner/${dv_prod_pwd} <<-EOP
				EXEC DBMS_MACADM.DISABLE_DV;
				EOP
			else
			echo -e "\e[31m*** Issues with dbvowner password of ${db_name}.. Pl check and update the password in setsid utility..."
			exit 1
		fi
	EOH
end

bash 'DB-shutdown-startup-after-Dv-disable' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
				echo -e "\e[97m"; echo ""
				echo "*** Shutting down the database"
				echo "*** Shutting down DB and Listener in ${rac_node1}"
				$ORACLE_HOME/bin/srvctl stop listener  -l listener_${db_name} -n ${rac_node1}
				$ORACLE_HOME/bin/srvctl stop instance -d ${db_name}_ucf -i ${ORACLE_SID} -o immediate
				#echo ""
				echo "*** Shutting down DB and Listener in ${rac_node2}"
				$ORACLE_HOME/bin/srvctl stop listener  -l listener_${db_name}  -n ${rac_node2}
				$ORACLE_HOME/bin/srvctl stop instance -d ${db_name}_ucf -i ${ORACLE_SID2} -o immediate
				echo ""; 

				echo "*** Starting up instance in restricted mode with srvctl ..."
				EPC_DISABLED=true ; export EPC_DISABLED

				echo "*** Starting up instance in restricted mode with srvctl ..."
				$ORACLE_HOME/bin/srvctl start instance -d ${db_name}_ucf -i $ORACLE_SID -o restrict

				$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
				alter database force logging;
				alter system disable restricted session;
				exit
				EOF
	
				echo "*** Starting up the Listener and Database..............."
				echo ""
				echo "$ORACLE_HOME/bin/srvctl start listener -l listener_${db_name} -n $rac_node1"	 > ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo " echo ' '" >>  ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo " echo '*** Starting second node instance.............................................'" >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo " echo ' '" >>  ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo "$ORACLE_HOME/bin/srvctl start instance -d ${db_name}_ucf -i $ORACLE_SID2 -o restrict" >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh
				echo " echo ' '" >>  ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo " echo '*** Starting second node listener.............................................'" >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh
				echo "$ORACLE_HOME/bin/srvctl start listener -l listener_${db_name}   -n $rac_node2"  >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh
				echo " echo ' '" >>  ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo " echo ' '" >>  ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo "echo '*** Checking First Node Listener ...........'" >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh	
				echo "$ORACLE_HOME/bin/tnsping LISTENER_$ORACLE_SID"  >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh	
				echo  "echo ''"  >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh
				echo " echo ' '" >>  ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 
				echo "echo 'Checking Second Node Listener ...........'" >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh				    
				echo "$ORACLE_HOME/bin/tnsping LISTENER_${ORACLE_SID2}"  >> ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh
				echo " echo ' '" >>  ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh 

				sh ${script_home}/${db_name}/db_listener_start_$ORACLE_SID.sh >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
				
				viewtemp='$option'
				a='$database'	
				b='$instance'	
				$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF
				set lines 1000
				col  OPEN_MODE  for a10
				col DB_UNIQUE_NAME for a20
				col NAME for a10
				select  INST_ID,NAME,OPEN_MODE, DB_UNIQUE_NAME, created from gv$a;
				set lines 1000
				col INSTANCE_NAME for a15
				col HOST for a10
				col INSTANCE_MODE for a15
				col DATABASE_STATUS for a15
				select  INST_ID ,INSTANCE_NUMBER,INSTANCE_NAME,substr(HOST_NAME,1,9)  "Host",STARTUP_TIME "StartupTime",STATUS ,BLOCKED,INSTANCE_MODE, DATABASE_STATUS from  gv$b;
				col INST_ID for 9
				col PARAMETER for a45
				col  VALUE for a10
				set lines 1000
				SELECT * FROM gv$viewtemp  WHERE PARAMETER = 'Oracle Database Vault';
				
				EOF
		EOH
end

bash 'FND_USER_PREFERENCES_TABLE_EXPORT' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
					echo -e "\e[33m*** FND_USER_PREFERENCES_TABLE_EXPORT"
					echo -e "\e[97m"
					$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
					create or replace directory refresh as '/u01/app/oracle/refresh/refresh';
					grant read,write on directory refresh to public;
					EOF

					echo "*** Starting export of table fnd_user_preferences_${db_name}..."
					########### The password needs to be changed
					cd /u01/app/oracle/refresh/refresh
					sys_con='\"/ as sysdba\"'
					rm -rf FND_USER_PREFERENCES_${db_name}.dmp FND_USER_PREFERENCES_${db_name}.log
					$ORACLE_HOME/bin/expdp ${sys_con}  tables=apps.FND_USER_PREFERENCES_${db_name} directory=refresh dumpfile=FND_USER_PREFERENCES_${db_name}.dmp logfile=export_FND_USER_PREFERENCES_${db_name}.log >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
					echo ""
			EOH
end
=end
