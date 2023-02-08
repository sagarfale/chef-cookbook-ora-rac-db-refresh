### Author : Sagar Fale
###
####email settings

default['chef']['verify']['notify_email'] = 'sagar.fale@oracle.com'

######### DB Related attributes 

default['db']['rdbms']['ver'] = '' 
default['db']['crs']['ver'] = ''
default['db']['rdbms']['ORACLE_BASE']  = '/u01/app/oracle'
default['db']['rdbms']['ORA_CRS_HOME']  = '/u01/app/' + "#{node['db']['crs']['ver']}" + '/grid'
default['db']['rdbms']['DB_NAME'] = ''
default['db']['rdbms']['db_name'] = ''
default['db']['rdbms']['ORACLE_SID'] = '' 
default['db']['rdbms']['ORACLE_SID2'] = ''
default['db']['rdbms']['ORACLE_HOME'] = '/u01/app/oracle/product/' + "#{node['db']['rdbms']['ver']}" + "_" + "#{node['db']['rdbms']['DB_NAME']}"
default['db']['rdbms']['ORA_NLS10'] = "#{default['db']['rdbms'] ['ORACLE_HOME']}" + "/nls/data/9idata"
default['db']['rdbms']['PATH'] = '/u01/app/system_scripts/local/bin:/u01/app/system_scripts/local/bin:/usr/local/bin:/u01/app/oracle/product/' + '/u01/app/oracle/product/' + "#{node['db']['rdbms']['ver']}" + "_" + "#{node['db']['rdbms']['DB_NAME']}" + '/bin:/bin:/usr/bin:/usr/ccs/bin:/u01/app/oracle/product/' + '/u01/app/oracle/product/' + "#{node['db']['rdbms']['ver']}" + "_" + "#{node['db']['rdbms']['DB_NAME']}" + '/ctx/bin:/usr/etc:/usr/sbin:.:/usr/local/etc:/u01/app/oracle/admin/' + "#{node['db']['rdbms']['ORACLE_SID']}" + '/bin:/u01/app/oracle/admin/' + "#{node['db']['rdbms']['ORACLE_SID']}" + '/dba/bin:/u01/app/oracle/product/' + '/u01/app/oracle/product/' + "#{node['db']['rdbms']['ver']}" + "_" + "#{node['db']['rdbms']['DB_NAME']}" + '/OPatch:/u01/app/' + "#{default['db']['crs']['ver']}" + '/grid/bin:/sbin:.'
default['db']['rdbms']['rac_node1'] = ''
default['db']['rdbms']['rac_node2'] = ''
default['db']['rdbms']['source_db_name'] = ''
default['db']['rdbms']['source_db_sid1'] = ''
default['db']['rdbms']['source_db_host'] =  ''
default['db']['rdbms']['SOURCE_ORACLE_HOME'] = '/u01/app/oracle/product/' + "#{node['db']['rdbms']['ver']}" + "_" + "#{node['db']['rdbms']['source_db_name']}"
default['db']['rdbms']['script_home'] = '/u01/app/system_scripts/scripts/DB_REFRESH_CHEF'
default['db']['rdbms']['LD_LIBRARY_PATH'] = "#{default['db']['rdbms']['ORACLE_HOME']}" + '/lib:' + "#{default['db']['rdbms']['PATH']}"
default['db']['rdbms']['target_db_host'] =  ''
default['db']['rdbms']['target_db_refresh_port'] =  ''

#####  env for 12c

default['db']['rdbms']['env_12c'] = {'ORACLE_BASE' => node['db']['rdbms']['ORACLE_BASE'],
									'ORA_CRS_HOME' => node['db']['rdbms']['ORA_CRS_HOME'], 
									'DB_NAME' => node['db']['rdbms']['DB_NAME'], 
									'db_name' => node['db']['rdbms']['db_name'], 
									'ORACLE_SID' => node['db']['rdbms']['ORACLE_SID'],
				    				'ORACLE_SID2' => node['db']['rdbms']['ORACLE_SID2'],
				     				'ORACLE_HOME' => node['db']['rdbms']['ORACLE_HOME'],
				    				'ORA_NLS10' => node['db']['rdbms']['ORA_NLS10'],
				     				'PATH' => node['db']['rdbms']['PATH'],
				     				'rac_node1' => node['db']['rdbms']['rac_node1'],
								    'rac_node2' => node['db']['rdbms']['rac_node2'],
								    'source_db_name' => node['db']['rdbms']['source_db_name'],
								    'source_db_sid1' => node['db']['rdbms']['source_db_sid1'],								    
								    'script_home' => node['db']['rdbms']['script_home'],
								    'LD_LIBRARY_PATH' => node['db']['rdbms']['LD_LIBRARY_PATH'],
									'ver' => node['db']['rdbms']['ver'],
									'source_db_host' => node['db']['rdbms']['source_db_host'],
									'SOURCE_ORACLE_HOME' => node['db']['rdbms']['SOURCE_ORACLE_HOME'],
									'notify_email' => node['chef']['verify']['notify_email'],
									'target_db_host' => node['db']['rdbms']['target_db_host'],
									'target_db_refresh_port' => node['db']['rdbms']['target_db_refresh_port']}

####################################################################################################
#'syspwd' => node['db']['rdbms']['syspwd'],
#### ASM/GRID related attributes

default['grid']['crs-asm']['ver'] = '' 
default['grid']['crs-asm']['ORACLE_BASE']  = '/u01/app/oracle/product'
default['grid']['crs-asm']['ORACLE_SID'] = '' 
default['grid']['crs-asm']['ORACLE_HOME']  = '/u01/app/' + "#{node['grid']['crs-asm']['ver']}" + '/grid'
default['grid']['crs-asm']['TNS_ADMIN']  = "#{default['grid']['crs-asm']['ORACLE_HOME']}" + '/network/admin/'
default['grid']['crs-asm']['asm_node1'] = ''
default['grid']['crs-asm']['asm_node2'] = ''
default['grid']['crs-asm']['PATH'] = '/u01/app/system_scripts/local/bin:/u01/app/system_scripts/local/bin:/usr/local/bin:/u01/app/' + "#{default['grid']['crs-asm']['ver']}" + '/grid/bin:/bin:/usr/bin:/usr/ccs/bin:/u01/app/' + "#{default['grid']['crs-asm']['ver']}" + '/grid/ctx/bin:/usr/etc:/usr/sbin:.:/usr/local/etc:/u01/app/' + "#{default['grid']['crs-asm']['ver']}" + '/grid/OPatch'
default['grid']['crs-asm']['LD_LIBRARY_PATH'] = "#{default['grid']['crs-asm']['ORACLE_HOME']}" + '/lib:' + "#{default['grid']['crs-asm']['ORACLE_HOME']}" + '/ctx/lib:/usr/lib:/usr/X11R6/lib'
default['grid']['crs-asm']['asm_directories'] = '+DATA2_UBA/admin/' + "#{node['db']['rdbms']['db_name']}" + '/db/' + ' ' + '+DATA2_UBA/' + "#{node['db']['rdbms']['db_name']}" + '_UCF/' + ' ' +  '+RECO2_UBA/admin/' + "#{node['db']['rdbms']['db_name']}"  + '/db/'
###### Env settings for ASM and Grid Infra

default['grid']['crs-asm']['asm_env_12c'] = {'ORACLE_BASE' => node['grid']['crs-asm']['ORACLE_BASE'],			
									'ORACLE_SID' => node['grid']['crs-asm']['ORACLE_SID'],
				     				'ORACLE_HOME' => node['grid']['crs-asm']['ORACLE_HOME'],
				     				'PATH' => node['grid']['crs-asm']['PATH'],
				     				'asm_node1' => node['grid']['crs-asm']['asm_node1'],
								    'asm_node2' => node['grid']['crs-asm']['asm_node2'],
								    'LD_LIBRARY_PATH' => node['grid']['crs-asm']['LD_LIBRARY_PATH'],
									'ver' => node['grid']['crs-asm']['ver'],
									'TNS_ADMIN' => node['grid']['crs-asm']['TNS_ADMIN'],
									'db_name' => node['db']['rdbms']['db_name'],
									'asm_directories' => node['grid']['crs-asm']['asm_directories'],
									'target_db_host' => node['db']['rdbms']['target_db_host'],
									'target_db_refresh_port' => node['db']['rdbms']['target_db_refresh_port'],
									'target_db_sid1' => node['db']['rdbms']['ORACLE_SID'],									
									'notify_email' => node['chef']['verify']['notify_email']}

####################################################################################################