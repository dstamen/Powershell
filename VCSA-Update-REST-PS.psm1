################################################################################################################################################
# Powershell Modue for VCSA Updating using REST API
# Twitter: @davidstamen
# http://davidstamen.com/2018/12/26/patching-the-vcenter-server-appliance-vcsa-using-the-rest-api-part-2-powershell-module/
################################################################################################################################################

########################
#thanks to Rudi Martinsen for this section
#Skip ssl stuff...
########################
add-type @" 
    using System.Net; 
    using System.Security.Cryptography.X509Certificates; 
    public class TrustAllCertsPolicy : ICertificatePolicy { 
        public bool CheckValidationResult( 
            ServicePoint srvPoint, X509Certificate certificate, 
            WebRequest request, int certificateProblem) { 
            return true; 
        } 
    } 
"@  
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

########################
## Environment params ##
########################
$vcenter = "vc.lab.local
$username = "administrator@vsphere.local"
$pass = "P@ssw0rd1!"
$ssopass = "P@ssw0rd1!"

################
## End params ##
################

#Get VCSA Backup Policy
function Get-VCSAUpdatePolicy {
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/policy"

    #Fetch data
    $Response = Invoke-RestMethod -Method Get -Headers $sessionheader -Uri $Uri
    $Response.Value
}
function Get-VCSAUpdateStatus {
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update"

    #Fetch data
    $Response = Invoke-RestMethod -Method Get -Headers $sessionheader -Uri $Uri
    $Response.Value
}
function Get-VCSAUpdate {
    Param(
        [parameter(Mandatory=$false)]
        [String]
        $Source 
        )
        
    if ($Source -eq "Local") {
        $SourceType = "LOCAL"
    }
    elseif ($Source -eq "Online") {
        $SourceType = "LOCAL_AND_ONLINE"
        
    }
    else {
        $SourceType = "LOCAL_AND_ONLINE"
    } 

    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/pending?source_type=$SourceType"

    #Fetch data
    $Response = Invoke-RestMethod -Method Get -Headers $sessionheader -Uri $Uri
    $Response.Value
}

function Get-VCSAUpdateDetail {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Version 
        ) 
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/pending/$version"

    #Fetch data
    $Response = Invoke-RestMethod -Method Get -Headers $sessionheader -Uri $Uri
    $Response.Value
}
function Get-VCSAUpdateStaged {
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{
        'vmware-api-session-id' = $token
    }


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/staged"

    #Fetch data
    $Response = Invoke-RestMethod -Method Get -Headers $sessionheader -Uri $Uri
    $Response.Value
}

function Copy-VCSAUpdate {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Version 
        ) 
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/pending/$Version"
    $Action = "?action=stage"

    #Fetch data
    $Response = Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action
    $Response.Value
}
function Remove-VCSAUpdate {
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{
        'vmware-api-session-id' = $token
    }


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/staged"

    #Fetch data
    $Response = Invoke-RestMethod -Method Delete -Headers $sessionheader -Uri $Uri
    $Response.Value
}
function Start-VCSAUpdatePrecheck {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Version 
        ) 
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/pending/$Version"
    $Action = "?action=precheck"

    #Fetch data
    $Response = Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action
    $Response.Value
}
function Start-VCSAUpdateValidate {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Version 
        ) 
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/pending/$Version"
    $Action = "?action=validate"

    $body = @{
        user_data = @(
            @{
            value = $ssopass
            key = "vmdir.password"
            }
        )
     } | ConvertTo-Json

    #Fetch data
    #Write-Host = "Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action -Body $Body -ContentType "application/json""
    $Response = Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action -Body $Body -ContentType "application/json"
    $Response.Value
}

function Start-VCSAUpdateInstall {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Version 
        ) 
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/pending/$Version"
    $Action = "?action=install"

    $body = @{
        user_data = @(
            @{
            value = $ssopass
            key = "vmdir.password"
            }
        )
     } | ConvertTo-Json

    #Fetch data
    #Write-Host = "Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action -Body $Body -ContentType "application/json""
    $Response = Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action -Body $Body -ContentType "application/json"
    $Response.Value
}
function Start-VCSAUpdateStageandInstall {
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Version 
        ) 
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update/pending/$Version"
    $Action = "?action=stage-and-install"

    $body = @{
        user_data = @(
            @{
            value = $ssopass
            key = "vmdir.password"
            }
        )
     } | ConvertTo-Json

    #Fetch data
    #Write-Host = "Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action -Body $Body -ContentType "application/json""
    $Response = Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action -Body $Body -ContentType "application/json"
    $Response.Value
}
function Stop-VCSAUpdate {
    $BaseUri = "https://$vcenter/rest/"

    #Authenticate to vCenter
    $SessionUri = $BaseUri + "com/vmware/cis/session"
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($UserName+':'+$Pass))
    $header = @{
    'Authorization' = "Basic $auth"
    }
    $token = (Invoke-RestMethod -Method Post -Headers $header -Uri $SessionUri).Value
    $sessionheader = @{'vmware-api-session-id' = $token}


    #API Endpoints
    $Uri = $BaseUri + "appliance/update"
    $Action = "?action=cancel"


    #Fetch data
    $Response = Invoke-RestMethod -Method Post -Headers $sessionheader -Uri $Uri$Action
    $Response.Value
}