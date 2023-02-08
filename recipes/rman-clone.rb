# Cookbook Name:: cookbook_db_refresh
# Recipe :: rman-clone
# Copyright 2017, Oracle
# All rights reserved - Do Not Redistribute
# Author : Sagar Fale

bash 'DB-REFRESH-CLONING' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
				#clear	
				echo -e "\e[33m*** Starting RMAN Clone..."
				echo -e "\e[97m"
				if [ ! -f ${script_home}/${db_name}/refresh_first_run_${ORACLE_SID}.lock ];
				then		
						temp=`date +%d-%b-%Y:%H`
						[ -f $ORACLE_HOME/dbs/init$ORACLE_SID.ora ] && mv $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.bkp_${temp} || echo ""
						[ -f $ORACLE_HOME/dbs/orapw$ORACLE_SID ] && cp $ORACLE_HOME/dbs/orapw$ORACLE_SID $ORACLE_HOME/dbs/orapw$ORACLE_SID.bkp_${temp} || echo ""
						[ -f $ORACLE_HOME/dbs/init$ORACLE_SID.ora.bkp.f1 ] && mv $ORACLE_HOME/dbs/init$ORACLE_SID.ora.bkp.f1 $ORACLE_HOME/dbs/init$ORACLE_SID.ora.bkp.f1_${temp} || echo ""					   
						
						$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
						set pagesize 0 feedback off verify off heading off echo off;
						alter system set cluster_database=FALSE scope=spfile sid='*';
						create pfile='$ORACLE_HOME/dbs/init$ORACLE_SID.ora' from spfile;
						create pfile='$ORACLE_HOME/dbs/init$ORACLE_SID.ora.bkp.f1' from spfile;
						EOF

						$ORACLE_HOME/bin/srvctl stop listener -l listener_${db_name}   -n $rac_node2
						$ORACLE_HOME/bin/srvctl stop instance -d ${db_name}_ucf -i $ORACLE_SID2 -o immediate
						$ORACLE_HOME/bin/srvctl stop listener  -l listener_${db_name}     -n $rac_node1

						echo ""
						echo "*** Dropping Database $DB_NAME..."
						sleep 60
						$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
						STARTUP FORCE MOUNT;
						ALTER SYSTEM ENABLE RESTRICTED SESSION;
						DROP DATABASE;
						EOF

						echo "*** Copying Password file.."
						cp $ORACLE_HOME/dbs/orapw${source_db_sid1}  $ORACLE_HOME/dbs/orapw$ORACLE_SID
						echo "*** Modifying OCR Spfile... "
						$ORACLE_HOME/bin/srvctl modify database -db ${db_name}_ucf -spfile '' 
						ps -ef |grep -i pmon |grep -i $ORACLE_SID
						echo "*** Drop Database ${db_name} Completed..."
						
						sed -i '/db_name/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/db_file_name_convert/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/log_file_name_convert/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/cluster_database/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/control_files/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/log_archive_format/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/$ORACLE_SID2.local_listener/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/$ORACLE_SID.local_listener/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/local_listener/d' $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						sed -i '/db_unique_name/d'  $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						echo "*.db_name=${db_name}" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						echo "*.cluster_database=FALSE" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						echo "*.log_archive_format='${db_name}_%t_%s_%r.arc'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						echo "*.db_file_name_convert='+DATA/admin/${source_db_name}/db/','+DATA_UBA/admin/${db_name}/db/','+RECO/admin/${source_db_name}/db/','+RECO_UBA/admin/${db_name}/db/','+DATA/${source_db_name}_XUCF/','+DATA_UBA/${db_name}_UCF/'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						echo "*.log_file_name_convert='+DATA/admin/${source_db_name}/db/','+DATA_UBA/admin/${db_name}/db/','+RECO/admin/${source_db_name}/db/','+RECO_UBA/admin/${db_name}/db/'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						echo "*.control_files='+DATA_UBA/admin/${db_name}/db/control_01.dbf', '+DATA_UBA/admin/${db_name}/db/control_02.dbf', '+DATA_UBA/admin/${db_name}/db/control_03.dbf'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
						cp -rf $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.before_rac_conversion

						echo "*** Shutting DB.. Pl standby..."
						
						$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOP >> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
						shut abort;
						STARTUP NOMOUNT pfile='$ORACLE_HOME/dbs/init$ORACLE_SID.ora';
						EXIT;
						EOP
								
						bct=`date +"%m_%d_%Y_%H_%M_%S"`
						cat > ${script_home}/${db_name}/${db_name}_duplicate.rman <<-EOP
						run{
						SET NEWNAME FOR BLOCK CHANGE TRACKING FILE TO '+DATA_UBA/${db_name}_UCF/${db_name}_${bct}_ctl.bct';
						DUPLICATE DATABASE TO ${db_name} FROM ACTIVE DATABASE
						SPFILE
						parameter_value_convert ('${source_db_name}','${db_name}')
						set db_file_name_convert='+DATA/admin/${source_db_name}/db/','+DATA_UBA/admin/${db_name}/db/','+RECO/admin/${source_db_name}/db/','+RECO_UBA/admin/${db_name}/db/','+DATA/${source_db_name}_XUCF/','+DATA_UBA/${db_name}_UCF/','+RECO_ABA/admin/${source_db_name}/db/','+DATA_UBA/admin/${db_name}/db/'
						set log_file_name_convert='+DATA/admin/${source_db_name}/db/','+DATA_UBA/admin/${db_name}/db/','+RECO/admin/${source_db_name}/db/','+RECO_UBA/admin/${db_name}/db/'
						set audit_file_dest='$ORACLE_BASE/admin/${db_name}/adump'
						set core_dump_dest='$ORACLE_BASE/admin/${db_name}/adump'
						set control_files='+DATA_UBA/admin/${db_name}/db/control_01.dbf', '+DATA_UBA/admin/${db_name}/db/control_02.dbf', '+DATA_UBA/admin/${db_name}/db/control_03.dbf'
						set cluster_database='false'
						set db_unique_name='${db_name}_ucf'
						set db_name='${db_name}'
						set local_listener=''
						set log_archive_format = '${db_name}_%t_%s_%r.arc'
						set db_recovery_file_dest='+RECO_UBA'
						;
						}
						EOP
						#echo ""
						echo "*** Starting Duplicating $db_name from ${source_db_name}DR..."
						sys_prod_pwd=`getpwd -e ${source_db_name} sys`				
						> ${script_home}/${db_name}/refresh_${ORACLE_SID}.log
						echo "$ORACLE_HOME/bin/rman target  sys/${sys_prod_pwd}@${source_db_name}_xucf auxiliary  sys/${sys_prod_pwd}@${ORACLE_SID}_refresh   cmdfile='${script_home}/${db_name}/${db_name}_duplicate.rman'  log='${script_home}/${db_name}/refresh_${ORACLE_SID}.log' " > ${script_home}/${db_name}/refresh_${ORACLE_SID}.sh;
						echo "Pl check script .. sleeping 120 sec...."
						sleep 120
						nohup sh ${script_home}/${db_name}/refresh_${ORACLE_SID}.sh  &
						if [ $? -eq 0 ]
						then
							echo "success"
						else
							echo "failure"
							> ${script_home}/${db_name}/refresh_${ORACLE_SID}.lock
							> ${script_home}/${db_name}/refresh_first_run_${ORACLE_SID}.lock
							exit
						fi
				fi
			EOH
end

=begin 
bash 'DB-REFRESH-CLONING-AFTER-1st-PASS' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
				#clear	
				echo -e "\e[33m*** Starting RMAN Clone..."
				echo -e "\e[97m"
				if [ -f ${script_home}/${db_name}/refresh_first_run_${ORACLE_SID}.lock ];
				then

					echo "*** Lock file present ..."
				    echo "*** Running the script ${script_home}/refresh_${ORACLE_SID}.sh ... "
				    nohup sh ${script_home}/${db_name}/refresh_${ORACLE_SID}.sh  &	
						    if [ $? -eq 0 ]
							then
								echo -e "\e[32m*** Restore started on this host "#{node[:db][:rdbms][:rac_node1]}" ....." ; 			  		   		
								sleep 300
							else
						    	echo "" ; echo -e "\e[31m*** Restore NOT started on this host "#{node[:db][:rdbms][:rac_node1]}" ....." >&2
						  		mailx -s "Restore NOT started on this host : "#{node[:db][:rdbms][:rac_node1]}" ....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
						  		echo -e "\e[39m"
						  		exit 1							
						  	fi				    
				else
					echo "Lock file Not present!" && exit 0	    
				fi

			EOH
end
=end

=begin
bash 'DB-REFRESH-CLONING' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
	nohup sh ${script_home}/refresh_${ORACLE_SID}.sh  &	
	if [ $? -eq 0 ]
		then
		echo "sucess"
	else
		echo "failure"
	fi
	EOH
end
=end