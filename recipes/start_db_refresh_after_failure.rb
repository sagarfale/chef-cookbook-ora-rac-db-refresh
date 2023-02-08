# Cookbook Name:: DB-REFRESH-CLONING-AFTER-1st-PASS
# Recipe :: rman-clone
# Copyright 2017, Oracle
# All rights reserved - Do Not Redistribute
# Author : Sagar Fale

bash 'DB-REFRESH-CLONING-AFTER-FAILURE' do 
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