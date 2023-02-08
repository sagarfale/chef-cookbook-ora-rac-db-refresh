### Cookbook : cookbook_db_refresh
### Recipe : ssh-checks
### Author : Sagar Fale
### Version : 0.1

bash 'checking_ssh_connectivity' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
	echo ""
	ssh -q -o BatchMode=yes -o ConnectTimeout=10 ${source_db_host} exit
	if [ $? -ne 0 ]
	then
	  	# Do stuff here if example.com SSH is down
	  	mailx -s "SSH connectivity NOT established from host "#{node[:db][:rdbms][:rac_node1]}" to "#{node['db']['rdbms']['source_db_host']}"....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
	  	error_exit()
		{
		echo -e "\e[31m*** Aborting the execution ...."
		echo  "*** $1" 1>&2
		echo -e "\e[39m"
		exit 1
		}
		error_exit "SSH connectivity failed ...."
	else
		echo -e "\e[32m*** SSH connectivity established ...."
		mailx -s "SSH connectivity Established from host "#{node[:db][:rdbms][:rac_node1]}" to "#{node['db']['rdbms']['source_db_host']}"....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
	fi
	EOH
end