# Cookbook Name:: cookbook_db_refresh
# Recipe :: sourceDB-files-copy
# Copyright 2017, Oracle
# All rights reserved - Do Not Redistribute
# Author : Sagar Fale

bash 'sourceDB-password-files-copy' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
			 echo "";echo -e "\e[33m*** Copying password of source DB ${source_db_sid1} to target host ${rac_node1}..."; echo "";
			 dir_temp=`date +%d-%b-%Y-%H-%M-%S`
			 mkdir -p $ORACLE_HOME/dbs/${dir_temp}
			 cd $ORACLE_HOME/dbs
			 mv orapw* ${dir_temp}
			 scp oracle@${source_db_host}:$SOURCE_ORACLE_HOME/dbs/orapw${source_db_sid1} .
			 cp  -rf orapw${source_db_sid1} orapw${ORACLE_SID} 

			if [ $? -eq 0 ]
				then
					echo -e "\e[32m*** Copying of the password files on this host "#{node[:db][:rdbms][:rac_node1]}" ....." ; 			  		   		
			else
			    	echo "" ; echo -e "\e[31m*** Not able to copy password files on this host "#{node[:db][:rdbms][:rac_node1]}" ....." >&2
			  		mailx -s "Not able to copy password files on this host : "#{node[:db][:rdbms][:rac_node1]}" ....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
			  		echo "";
			  		echo -e "\e[31m*** Aborting the execution ..."
			  		echo -e "\e[97m"
					exit 1
			fi
		EOH
end

####

bash 'SourceDB-TDE-Wallet-files-copy' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
				echo "";echo -e "\e[33m*** Copying TDE-Wallet files of source DB ${source_db_sid1} to target host ${rac_node1}..."; echo "";
				mkdir -p /etc/oracle/tde_wallets/${db_name}
				dir_temp=`date +%d-%b-%Y-%H-%M-%S`
				cd /etc/oracle/tde_wallets/${db_name}
				mkdir $dir_temp
				mv *wallet* $dir_temp
				scp oracle@${source_db_host}:/etc/oracle/tde_wallets/${source_db_name}/*wallet* /etc/oracle/tde_wallets/${db_name}/

				if [ $? -eq 0 ]
				then
					echo -e "\e[32m*** Copying of the TDE wallet files on this host "#{node[:db][:rdbms][:rac_node1]}" ....." ; 			  		   		
				else
			    	echo "" ; echo -e "\e[31m*** Not able to copy the TDE wallet files on this host "#{node[:db][:rdbms][:rac_node1]}" ....." >&2
			  		mailx -s "Not able to copy the TDE wallet files on this host : "#{node[:db][:rdbms][:rac_node1]}" ....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
			  		echo "";
			  		echo -e "\e[31m*** Aborting the execution ..."
			  		echo -e "\e[97m"
					exit 1
				fi

				scp *wallet* oracle@${rac_node2}:/etc/oracle/tde_wallets/${db_name}/

				if [ $? -eq 0 ]
				then
					echo -e "\e[32m*** Copying of the TDE wallet files on this host "#{node[:db][:rdbms][:rac_node2]}" ....." ; 			  		   		
				else
			    	echo "" ; echo -e "\e[31m*** Not able to copy the TDE wallet files on this host "#{node[:db][:rdbms][:rac_node2]}" ....." >&2
			  		mailx -s "Not able to copy the TDE wallet files on this host : "#{node[:db][:rdbms][:rac_node2]}" ....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
			  		echo "";
			  		echo -e "\e[31m*** Aborting the execution ..."
			  		echo -e "\e[97m"
					exit 1
				fi
			EOH
end