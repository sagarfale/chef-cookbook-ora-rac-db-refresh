### Cookbook : cookbook_db_refresh
### Recipe : getpwd-checks
### Author : Sagar Fale
### Version : 0.1
bash 'checking_getpwd_utility' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
	clear
	> ${script_home}/${db_name}/refresh_${ORACLE_SID}_main.log
	echo -e "\e[33m   *** GETPWD verification started ..."
	echo -e "\e[97m"
	which getpwd  2> /dev/null

	if [ $? -eq 0 ]
	then
		echo -e "\e[32m*** GETPWD utility is avaiable on this host "#{node[:db][:rdbms][:rac_node1]}" ....." ; 			  		   		
    else
    	echo "" ; echo -e "\e[31m*** GETPWD utility is NOT avaiable on this host "#{node[:db][:rdbms][:rac_node1]}" ....." >&2
  		mailx -s "GETPWD utility is NOT available on this host : "#{node[:db][:rdbms][:rac_node1]}" ....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
  		echo "";
  		error_exit()
		{
		echo -e "\e[31m*** Aborting the execution ..."
		echo  "*** $1" 1>&2
		echo -e "\e[39m"
		exit 1
		}
  		error_exit "GETPWD utility NOT is avaiable on this host"
  		#mailx -s "GETPWD utility is available on this host : "#{node[:db][:rdbms][:rac_node1]}" ..... " "#{node[:chef][:verify][:notify_email]}" </dev/null
  		#echo ""  		
  	fi
  	EOH
end

