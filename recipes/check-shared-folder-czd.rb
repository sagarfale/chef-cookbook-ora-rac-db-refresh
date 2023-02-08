### Cookbook : cookbook_db_refresh
### Recipe : check-shared-folder-czd
### Author : Sagar Fale
### Version : 0.1
bash 'check-shared-folder-czd' do 
	user 'oracle'
	group 'oinstall'
	environment (node[:db][:rdbms][:env_12c])
	code <<-EOH
		ls -l /scp_refresh/${db_name}/CZD_shared_arch/
		if [ $? -eq 0 ];
			then
  			 	echo -e "\e[32m*** /scp_refresh/${db_name}/CZD_shared_arch/ is present...  verified Successfully"
			elif [ $? -eq 255 ]; then
				echo -e "\e[32m*** /scp_refresh/${db_name}/CZD_shared_arch/ Directories already present..." >&2
  				echo ""
  			else 
  				echo -e "\e[31m >>> /scp_refresh/${db_name}/CZD_shared_arch/ may not NOT present.. Pl check" >&2
  				mkdir -p /scp_refresh/${db_name}/CZD_shared_arch/
  				echo ""
			fi
		EOH
end