### Cookbook : cookbook_db_refresh
### Recipe : rman-restore-status
### Author : Sagar Fale
### Version : 0.1

bash 'rman-restore-status' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
			echo -e "\e[97m"
			echo "Please wait for 5 min to get RMAN status....."
			sleep 300

			func_char_display(){
								output="\r"
								output="$output ["
								echo -ne "$output"
								for i in $(seq 1 $1); do
								echo -ne '#'
								done
								echo -ne "]$i%\033[0K\r"
								sleep 1
							}

			current_progress=0
			total_progress=95

			func_db(){
						view_temp='$SESSION_LONGOPS'
						current_progress=`$ORACLE_HOME/bin/sqlplus -s / as sysdba <<-EOF
						set pagesize 0 feedback off verify off heading off echo off;
						select round((SOFAR*100/decode(TOTALWORK,0,SOFAR,TOTALWORK))) PCT_DONE  FROM  gv$view_temp   WHERE  TOTALWORK != 0 AND SOFAR <> TOTALWORK and MESSAGE LIKE '%aggre%' AND OPNAME like 'RMAN%';
						exit ;
						EOF`
						return "$current_progress";
					}

			while [ $current_progress -lt $total_progress ];
				do
					func_db;
					func_char_display  $current_progress
					sleep 5
				done
			printf "\n"
			echo ""
		EOH
end


bash 'rman-restore-pid-check' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
			echo ""
			ps -ef |grep -i refresh_${ORACLE_SID}.sh
			echo ""
			ps aux | grep refresh_${ORACLE_SID}.sh |grep -v grep
			while [ $? -eq 0 ]; do
	 			echo -n `date +%d-%b-%Y:%H:%M:%S` ; echo  " *** Pl wait. RMAN finshing tasks in progress........"
	 			sleep 10;
	 			ps aux | grep refresh_${ORACLE_SID}.sh |grep -v grep > /tmp/t2.log
				done
			echo "*** RMAN Job Finished... "
	EOH
end

bash 'rman_lock_files_removal' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
			rm -rf ${script_home}/refresh_${ORACLE_SID}.lock
			rm -rf ${script_home}/refresh_first_run_${ORACLE_SID}.lock
	EOH
end