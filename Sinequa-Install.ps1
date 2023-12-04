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
$SINEQUA_SITE_ROOT_PATH='IIS:\Sites\$SINEQUA_SITE_NAME\'
$SINEQUA_SITE_PROTOCOL=


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

# Test if UNC PATH or LOCAL PATH for Virtual Directory
# Todo : Boucle sur les Virtual Directory pour supprimer les anciens au cas ou
Remove-WebVirtualDirectory -Site '$SINEQUA_SITE_NAME' -Name $nomduvd -application $nom de la racine (/)

## Create Virtual Directory where physicalpath is an UNC-path (New-WebVirtualDirectory wont do)
New-Item $SINEQUA_SITE_ROOT_PATH$nomduvd -type VirtualDirectory -physicalPath '$vdphysicalpath'
  

# Ajout du mot de passe
Set-WebConfiguration -Filter "/system.applicationHost/sites/site[@name=$SINEQUA_SITE_NAME]/application[@path='/']/virtualDirectory[@path=$nomduvd]" -Value @{userName=$SINEQUA_USER_ACCOUNT; password=$SINEQUA_USER_PASSWORD}
 
# Ajout du SSO
# TODO
https://doc.sinequa.com/en.sinequa-es.v11/content/en.sinequa-es.how-to.implement-sso.html
$iisSiteName = "Default Web Site"
$iisAppName = "MyApp"
 
Write-Host Disable anonymous authentication
Set-WebConfigurationProperty -Filter '/system.webServer/security/authentication/anonymousAuthentication' -Name 'enabled' -Value 'false' -PSPath 'IIS:\' -Location "$iisSiteName/$iisAppName"
 
Write-Host Enable windows authentication
Set-WebConfigurationProperty -Filter '/system.webServer/security/authentication/windowsAuthentication' -Name 'enabled' -Value 'true' -PSPath 'IIS:\' -Location "$iisSiteName/$iisAppName"


Function Install-IIS {
    [cmdletbinding()]
    Param(
    )
    Begin {
        Write-Verbose "Starting IIS Installation"
    }
    Process {
        Install-WindowsFeature Web-Server
        Install-WindowsFeature Web-WebServer
        Install-WindowsFeature Web-Common-Http
        Install-WindowsFeature Web-Default-Doc
        Install-WindowsFeature Web-Dir-Browsing
        Install-WindowsFeature Web-Http-Errors
        Install-WindowsFeature Web-Static-Content
        Install-WindowsFeature Web-Health
        Install-WindowsFeature Web-Log-Libraries
        Install-WindowsFeature Web-Performance
        Install-WindowsFeature Web-Stat-Compression
        Install-WindowsFeature Web-Security
        Install-WindowsFeature Web-Filtering
        Install-WindowsFeature Web-Basic-Auth
        Install-WindowsFeature Web-Windows-Auth
        Install-WindowsFeature Web-App-Dev
        Install-WindowsFeature Web-Net-Ext45
        Install-WindowsFeature Web-Asp-Net45
        Install-WindowsFeature Web-ISAPI-Ext
        Install-WindowsFeature Web-ISAPI-Filter
        Install-WindowsFeature Web-Mgmt-Tools
        Install-WindowsFeature Web-Mgmt-Console
        Install-WindowsFeature Web-Scripting-Tools
        Install-WindowsFeature Web-Mgmt-Service
        }
    End {
        Write-Verbose "Ending IIS Installation"
    }
}

Function Create-SinequaService {
    [cmdletbinding()]
    Param(
    [Parameter(HelpMessage="(default netcorekestrel): indicates the WebApp type (net or netcorekestrel).")]
    [ValidateSet("net", "netcorekestrel")]
    [string]$SINEQUA_INSTALL_TYPE = "net",

    [Parameter(HelpMessage="Account who run the service. (default 'NetworkService').")]
    [string]$SINEQUA_USER_ACCOUNT,
        
    [Parameter()]
    [string]$SINEQUA_USER_DOMAIN,
    
    [Parameter()]
    [string]$SINEQUA_USER_PASSWORD,
    
    [Parameter(HelpMessage="indicates the node name.")]
    [string]$SINEQUA_NODE_NAME,
    
    [Parameter(HelpMessage="(default WebApp{computer_name}).")]
    [string]$SINEQUA_WEBAPP_NAME,
    
    [Parameter(HelpMessage="indicates the DataPath, cannot be filled if [--primaryNodes:CONNECTION_STRING] is not empty.")]
    [string]$SINEQUA_DATAPATH
    )
    Begin {
        Write-LogInfo "Starting $($MyInvocation.MyCommand)"
    }
    Process {
        Write-LogInfo "Processing ..."
        if ($SINEQUA_USER_ACCOUNT) {
            $option_account = '--user=' + $SINEQUA_USER_ACCOUNT
            if ($SINEQUA_USER_DOMAIN) {
                $option_domain = '--domain=' + $SINEQUA_USER_DOMAIN
            } 
            if ($SINEQUA_USER_PASSWORD) {
                $option_password = '--password=' + $SINEQUA_USER_PASSWORD
            }
        }
        if ($SINEQUA_NODE_NAME) {
            $option_nodename = '--nodename=' + $SINEQUA_NODE_NAME
        }
        if ($SINEQUA_WEBAPP_NAME) {
            $option_webappname = '--webappname=' + $SINEQUA_WEBAPP_NAME
        }
        if ($SINEQUA_DATAPATH) {
            $option_datapath = '-datapath:' + $SINEQUA_DATAPATH
        }

        # TODO : Mettre le bon répertoire !
        
        $proc = [System.Diagnostics.Process]::Start([System.Diagnostics.ProcessStartInfo]@{
        'FileName'               = "C:\Developpement\ymeunier\outils\BCV\jhove [PDF]\jhove.bat"
        'Arguments'              = '--type=' + $SINEQUA_INSTALL_TYPE + $option_account + $option_domain + $option_password + $option_nodename + $option_webappname + $option_datapath
        'CreateNoWindow'         = $true
        'UseShellExecute'        = $false
        'RedirectStandardOutput' = $true   # to get stdout to $proc.StandardOutput
        'RedirectStandardError'  = $true   # to get stderr to $proc.StandardError
        })
        $output = $proc.StandardOutput
        $error1 = $proc.StandardError
        $output.ReadToEnd()
        $error1.ReadToEnd()
        
        
        # TODO : Catch the response !
        # .\scmd.exe Install --type=$SINEQUA_INSTALL_TYPE $option_account $option_domain $option_password $option_nodename $option_webappname $option_datapath
        Write-LogInfo ".\scmd.exe Install --type=$SINEQUA_INSTALL_TYPE $option_account $option_domain $option_password $option_nodename $option_webappname $option_datapath"
    }
    End {
        Write-LogInfo "Ending $($MyInvocation.MyCommand)"
    }
}

Function Create-SinequaWebApp {
    [cmdletbinding()]
    Param(
    [Parameter(Mandatory,HelpMessage="Site name. if the name contains space, do not forget to double quote it.")]
    [string]$SINEQUA_SITE_NAME,

    [Parameter(HelpMessage="Hostname of the binding. To have an empty hostname in the binding, use two double-quote: """)]
    [string]$SINEQUA_SITE_HOSTBINDING = "'`"`"'",

    [Parameter(Mandatory,HelpMessage="The port the website listen to. Typical values are 80 or 443")]
    [int]$SINEQUA_WEBAPP_PORT,

    [Parameter(HelpMessage="IP address of the binding. To let the website listen from all addresses, use '*'")]
    [SupportsWildcards()]
    [string]$SINEQUA_SITE_IPBINDING = "'*'",
        
    [Parameter(HelpMessage="Protocol should be http or https. default: http")]
    [ValidateSet("http", "https")]
    [string]$SINEQUA_SITE_PROTOCOL = 'http' ,
    
    [Parameter(HelpMessage="The path inside the website where the application is plugged. default: /")]
    [string]$SINEQUA_SITE_APPLICATIONPATH = "'\'",

    [Parameter(HelpMessage="The name of the application pool. default: SINEQUA_SITE_NAME")]
    [string]$SINEQUA_SITE_APPLICATIONPOOL = $SINEQUA_SITE_NAME + "AppPool",
    
    [Parameter(HelpMessage="The name of the user used by the application pool. To use the default application pool user let it unset")]
    [string]$SINEQUA_USER_ACCOUNT,
        
    [Parameter(HelpMessage="The domain of the user used by the application pool. To use the default application pool user let it unset")]
    [string]$SINEQUA_USER_DOMAIN,
    
    [Parameter(HelpMessage="The password of the user used by the application pool. To use the default application pool user let it unset")]
    [string]$SINEQUA_USER_PASSWORD
    #[SecureString]$SINEQUA_USER_PASSWORD
    )
    Begin {
        Write-LogInfo "Starting $($MyInvocation.MyCommand)"
    }
    Process {
        Write-LogInfo "Processing ..."
        if ($SINEQUA_SITE_APPLICATIONPOOL) {
            
        }
        # TODO : Catch the response !
        # .\scmd.exe IISinstall '$SINEQUA_SITE_NAME' '""' '$SINEQUA_WEBAPP_PORT' '*' '$SINEQUA_SITE_PROTOCOL' '/' 'RP6_SINEQUAAppPool' '$SINEQUA_USER_ACCOUNT' '$SINEQUA_USER_DOMAIN' '$SINEQUA_USER_PASSWORD'
        Write-LogInfo ".\scmd.exe IISinstall $SINEQUA_SITE_NAME $SINEQUA_SITE_HOSTBINDING $SINEQUA_WEBAPP_PORT $SINEQUA_SITE_IPBINDING $SINEQUA_SITE_PROTOCOL $SINEQUA_SITE_APPLICATIONPATH $SINEQUA_SITE_APPLICATIONPOOL $SINEQUA_USER_ACCOUNT $SINEQUA_USER_DOMAIN $SINEQUA_USER_PASSWORD"
    }
    End {
        Write-LogInfo "Ending $($MyInvocation.MyCommand)"
    }
}
