### cookbook : cookbook_db_refresh
### Recipe : rac-conversion
### Author : Sagar Fale
### Version : 0.1

bash 'NON-RAC-TO-RAC-CONEVRSION-AND_DB-STARTUP' do 
		user 'oracle'
		group 'oinstall'		
		environment (node[:db][:rdbms][:env_12c])
		code <<-EOH	
				echo -e "\e[33m*** NON-RAC-TO-RAC-CONEVRSION-AND_DB-STARTUP"
				echo -e "\e[97m" 
				ps -ef |grep -i pmon |grep -i $ORACLE_SID
					
				echo "$ORACLE_SID2.local_listener='listener_$ORACLE_SID2'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
				echo "$ORACLE_SID.local_listener='listener_$ORACLE_SID'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
				echo "*.db_name='${db_name}'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
				echo "*.db_unique_name='${db_name}_ucf'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
				echo "*.cluster_database=TRUE" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora

				cd $ORACLE_HOME/dbs
				cp orapw${source_db_sid1} orapw${source_db_sid1}.bkp
				echo "*** Copying password file to second node........"
				scp orapw${source_db_sid1}.bkp oracle@$rac_node2:$ORACLE_BASE/product/${ver}_${db_name}/dbs/orapw$ORACLE_SID2
				echo "create spfile=`echo "'+DATA_UBA/admin/${db_name}/spfile/spfile${db_name}.ora'"` from pfile=`echo "'$ORACLE_HOME/dbs/init$ORACLE_SID.ora'"`;" > ${script_home}/${db_name}/create_spfile_$ORACLE_SID.sql
				
				$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOP >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
				shut immediate;			
				@${script_home}/${db_name}/create_spfile_$ORACLE_SID.sql
				exit
				EOP

				cp $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.f2
				>  $ORACLE_HOME/dbs/init$ORACLE_SID.ora
				echo "SPFILE='+DATA_UBA/admin/${db_name}/spfile/spfile${db_name}.ora'" >> $ORACLE_BASE/product/${ver}_${db_name}/dbs/init$ORACLE_SID.ora
				echo "$ORACLE_HOME/bin/srvctl modify database -db ${db_name}_ucf  -p '+DATA_UBA/admin/${db_name}/spfile/spfile${db_name}.ora'" > ${script_home}/${db_name}/srvctl_spfile_modify_$ORACLE_SID.sh 
				sh ${script_home}/${db_name}/srvctl_spfile_modify_$ORACLE_SID.sh
				
				echo "*** Starting DB and Listeners..............................."
									
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
				exit 
				EOF
				echo "";
		EOH
end
