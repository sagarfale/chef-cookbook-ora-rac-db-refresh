### cookbook : cookbook_db_refresh
### Recipe : asm-cheks
### Author : Sagar Fale
### Version : 0.1

bash 'asmcmd_check' do 
	user 'oracle'
	group 'oinstall'
	environment (node['grid']['crs-asm']['asm_env_12c'])
	code <<-EOH
		#echo ""
		echo "*** asmcmd verification started..."
		echo ""
		which $ORACLE_HOME/bin/asmcmd  2> /dev/null
		if [ $? -eq 0 ]
		then
  			echo -e "\e[32m*** asmcmd utility is available on this host "#{node[:db][:rdbms][:rac_node1]}" ...." ;
        ##echo ""
  			##mailx -s "asmcmd utility is available on this host : "#{node[:db][:rdbms][:rac_node1]}" ..... " "#{node[:chef][:verify][:notify_email]}" </dev/null
  			##echo "";
  			#####Just checking asm directories
  			#echo "asmcmd ls '+DATA2_UBA/admin/$db_name/db/'" > "#{node[:db][:rdbms][:script_home]}"/asm-check1.sh 
  			#echo "asmcmd ls '+DATA2_UBA/${db_name}_UCF/'"  >> "#{node[:db][:rdbms][:script_home]}"/asm-check1.sh 
  			#echo "asmcmd ls '+RECO2_UBA/admin/$db_name/db/'" >> "#{node[:db][:rdbms][:script_home]}"/asm-check1.sh  
  			echo $asm_directories 	 > "#{node[:db][:rdbms][:script_home]}"/${db_name}/asm-check.txt
  				for i in `cat "#{node[:db][:rdbms][:script_home]}"/${db_name}/asm-check.txt`
  					do
  					$ORACLE_HOME/bin/asmcmd ls ${i} > /tmp/t2.log
  					if [ $? -eq 0 ];
					  then
  						  #echo ""
    						echo "*** $i is present...  verified Successfully"
					  elif [ $? -eq 255 ]; then
						  echo -e "\e[32m*** $i Directories already present..." >&2
              echo -e "\e[97m"
  						echo ""
  					else 
  						echo -e "\e[31m >>> $i may not NOT present.. Pl check" >&2
  						##echo "############## Check here ############""
              echo -e "\e[97m"
  						$ORACLE_HOME/bin/asmcmd mkdir $i
  						echo ""
					fi
				done
				echo ""
	   		else
  			echo "" ; echo -e "\e[31m*** asmcmd utility is NOT avaiable on this host "#{node[:db][:rdbms][:rac_node1]}" ....." >&2
  			mailx -s "asmcmd utility is NOT available on this host : "#{node[:db][:rdbms][:rac_node1]}" ....."   "#{node[:chef][:verify][:notify_email]}" </dev/null
  			echo ""
        error_exit()
        {
        echo -e "\e[31m*** Aborting the execution ...."
        #echo -e "\e[31m*** $1" 1>&2
        echo -e "\e[39m"
        exit 1
        }
        error_exit "asmcmd utility is NOT avaiable on this host"
      fi
		EOH
end
