# Variables
$SINEQUA_INSTALL_DIRECTORY= 
$SINEQUA_USER_ACCOUNT= 
$SINEQUA_USER_DOMAIN=
$SINEQUA_USER_PASSWORD=
$SINEQUA_NODE_NAME=
$SINEQUA_NODE_PORT=
$SINEQUA_WEBAPP_NAME=
$SINEQUA_WEBAPP_PORT=
$SINEQUA_DATAPATH=
$SINEQUA_SITE_NAME=
$SINEQUA_SITE_PROTOCOL


# Install IIS Feature

Install-WindowsFeature  Web-Server                
Install-WindowsFeature  Web-WebServer             
Install-WindowsFeature  Web-Common-Http           
Install-WindowsFeature  Web-Default-Doc           
Install-WindowsFeature  Web-Dir-Browsing          
Install-WindowsFeature  Web-Http-Errors           
Install-WindowsFeature  Web-Static-Content        
Install-WindowsFeature  Web-Health                     
Install-WindowsFeature  Web-Log-Libraries         
Install-WindowsFeature  Web-Performance           
Install-WindowsFeature  Web-Stat-Compression      
Install-WindowsFeature  Web-Security              
Install-WindowsFeature  Web-Filtering             
Install-WindowsFeature  Web-Basic-Auth            
Install-WindowsFeature  Web-Windows-Auth          
Install-WindowsFeature  Web-App-Dev               
Install-WindowsFeature  Web-Net-Ext45             
Install-WindowsFeature  Web-Asp-Net45             
Install-WindowsFeature  Web-ISAPI-Ext             
Install-WindowsFeature  Web-ISAPI-Filter          
Install-WindowsFeature  Web-Mgmt-Tools            
Install-WindowsFeature  Web-Mgmt-Console          
Install-WindowsFeature  Web-Scripting-Tools       
Install-WindowsFeature  Web-Mgmt-Service

# Please don't forget to set path of Sinequa binaries

cd $SINEQUA_INSTALL_DIRECTORY\SINEQUA\website\bin
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Installation du service d'hébergement
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# [--type:TYPE] (default netcorekestrel): indicates the WebApp type (net or netcorekestrel).
# [--user:USER] (default 'NetworkService').
# [--domain:DOMAIN]
# [--password:PASSWORD]
# [--nodename:NODE_NAME]: indicates the node name.
# [--webappname:WEB_APP_NAME] (default WebApp{computer_name}).
# [--datapath:DATAPATH] indicates the DataPath, cannot be filled if [--primaryNodes:CONNECTION_STRING] is not empty.
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
.\scmd.exe Install --type=net --user=$SINEQUA_USER_ACCOUNT --domain=$SINEQUA_USER_DOMAIN --password=$SINEQUA_USER_PASSWORD --nodename=$SINEQUA_NODE_NAME --webappname=$SINEQUA_WEBAPP_NAME -datapath:$SINEQUA_DATAPATH
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Installation et configuration de la WebApp
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# <sitename> : Site name. if the name contains space, do not forget to double quote it.
# <host>     : Hostname of the binding. To have an empty hostname in the binding, use two double-quote: ""
# <port>     : The port the website listen to. Typical values are 80 or 443
# <ipaddress>: IP address of the binding. To let the website listen from all addresses, use '*'
# [protocol] : Protocol should be http or https. default: http
# [applicationpath]: The path inside the website where the application is plugged. default: /
# [apppoolname]: The name of the application pool. default: <sitename>
# [user]       : The name/domain/password of the user used by the application
# [domain]       pool. To use the default application pool user let it unset
# [password]
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------
.\scmd.exe IISinstall '$SINEQUA_SITE_NAME' '""' '$SINEQUA_WEBAPP_PORT' '*' '$SINEQUA_SITE_PROTOCOL' '/' 'RP6_SINEQUAAppPool' '$SINEQUA_USER_ACCOUNT' '$SINEQUA_USER_DOMAIN' '$SINEQUA_USER_PASSWORD'

# Modify port in config file
# TODO

