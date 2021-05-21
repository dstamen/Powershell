#VC Info
$vcname = "vc.lab.local"
$vcuser = "administrator@vsphere.local"
$vcpass = "VMware1!"
$cluster = "cluster01"

#fa Info
$pureuser = "pureuser"
$purepass = ConvertTo-SecureString "pureuser" -AsPlainText -Force
$purecred = New-Object System.Management.Automation.PSCredential -ArgumentList ($pureuser, $purepass)
$volcapacityTB = "5"


#Pure1 Cert Info. See https://davidstamen.com/2020/03/25/configuring-and-using-the-pure-storage-vsphere-plugin-with-pure1-authentication/ 
#on how to generate certificate
$Pure1Cert = Get-ChildItem -Path cert:\localmachine\my |Where-Object {$_.Subject -eq "CN=myPure1Cert"}
$Pure1AppID = "pure1:apikey:yourapikey"

#Connect to VC
$vcconn = Connect-VIServer $vcname -User $vcuser -Password $vcpass -WarningAction SilentlyContinue

#Connect to Pure1
New-PureOneRestConnection -certificate $Pure1Cert -pureAppID $Pure1AppID

Function Get-P1Datastores {
    #Get Datastores and Cycle Through which Arrays they are On.
    $Datastores = Get-Cluster $cluster | Get-Datastore | Where-Object {$_.Type -eq "VMFS"} | Sort-Object Name
    $ArraysToUse = @()
    $DatastoresToUse = @()

    foreach ($datastore in $Datastores) {
        Try {
        $array = Get-PureOneVolume -volumeName $datastore.Name | ? {$_.Name -eq $datastore.Name}|Select-Object arrays
        $arrayname = $array.arrays.name
        Write-Host "$datastore is located on $arrayname" -ForegroundColor Gray
            if ($ArraysToUse.Array -notcontains $arrayname) {
                $ArraysToUse += @([pscustomobject]@{'Array'=$arrayname;'Datastore'=$datastore;'FreeSpaceGB'=$Datastore.FreeSpaceGB})
            }
            $DatastoresToUse += @([pscustomobject]@{'Array'=$arrayname;'Datastore'=$datastore;'FreeSpaceGB'=$Datastore.FreeSpaceGB})

        }
        Catch {
            Write-Host "$datastore is not found in Pure1" -ForegroundColor Red
        }
    }
    $ArraysToUseName = $ArraysToUse.Array
    Write-Host "I can deploy to the following arrays: $ArraysToUseName " -ForegroundColor Green

    return $ArraysToUsename, $DatastoresToUse
}
Function Get-P1Load {
    Param (
        [Parameter(Mandatory=$True)]$ArraysToUseName
    )
    #For the Arrays Run BusyMeter to find Optimal Array
    $ArraysLoad = @()
    foreach ($flasharray in $ArraysToUseName) {
        Try {
            $days = "5"
            $hours = "1"
            $now = Get-Date
            $thendays = $now.AddDays(-$days)
            $thenhours = $now.AddHours(-$hours)
            $load = Get-PureOneArrayBusyMeter -objectName $flasharray -maximum -startTime $thenhours -endTime $now -granularity 3600000
            $loaddata = $load.data | Select-Object -Last 1
            $loadpercent = ($loaddata | Select-Object -Last 1) * 100
            $loadpercent = [math]::Round($loadpercent,2)
            #Write-Host "$flasharray has a maximum load of $loadpercent% over the last $days days" -ForegroundColor Gray
            Write-Host "$flasharray has a maximum load of $loadpercent% over the last $hours hours" -ForegroundColor Gray
        }
        Catch {
            Write-Host "BusyMeter Data for $flasharray is not found" -ForegroundColor Red
            Write-Host $_
        }
        if ($ArraysLoad -notcontains $flasharray) {
            $ArraysLoad += @([pscustomobject]@{'Array'=$flasharray;'Load'=$loadpercent})
        }
    }
    return $ArraysLoad
}
Function Get-P1LeastLoadArray {
    Param (
        [Parameter(Mandatory=$True)]$ArraysLoad
    )
    $LeastLoad = $ArraysLoad | Sort-Object Load | Select-Object -First 1
    $LeastLoadArray = $LeastLoad.Array
    $LeastLoadPercent = $LeastLoad.Load
    Write-Host "$LeastLoadArray has the least maximum load of $LeastLoadPercent % and will be used." -ForegroundColor Green

    return $LeastLoad
}


Function Get-P1LeastLoadArrayDS {
    Param (
        [Parameter(Mandatory = $True)]$LeastLoadArray,
        [Parameter(Mandatory=$True)]$DatastoresToUse


    )
    $DSonLeastLoadArray = $DatastoresToUse | Where-Object { $_.Array -eq $LeastLoadArray }
    $DSonLeastLoadArrayName = $DSonLeastLoadArray.Datastore.Name
    Write-Host "I can use the following Datastores: $DSonLeastLoadArrayName" -ForegroundColor Gray

    return $DSonLeastLoadArray
}
Function Get-P1DSFreeSpace {
    Param (
        [Parameter(Mandatory=$True)]$DSOnLeastLoadArray
    )
    $LeastFreeSpaceGBDS = $DSonLeastLoadArray | Sort-Object FreeSpaceGB | Select-Object -Last 1
    $LeastFreeSpaceGB = $LeastFreeSpaceGBDS.FreeSpaceGB
    $LeastFreeSpaceGBRounded = ([math]::Round($LeastFreeSpaceGB,2))
    $LeastLoadFreeSpaceGBDS = $LeastFreeSpaceGB.Array
    $LeastFreeSpaceGBDSName = $LeastFreeSpaceGBDS.Datastore.Name
    Write-Host "$LeastFreeSpaceGBDSName has the least capacity of $LeastFreeSpaceGBRounded GB and will be used." -ForegroundColor Cyan

return $LeastFreeSpaceGBDS.Datastore
}



Function Deploy-P1DS {
    Param (
        [Parameter(Mandatory=$True)]$LeastLoadArray
    )
    #Deploy VMFS Data Store
    $randomnum = (Get-Random)
    $dsname = "ds-$randomnum"
    $arrayname = $LeastLoadArray.Array
    Write-Host "Deploying $dsname on $arrayname ..." -ForegroundColor Green
    $faconn = New-PfaConnection -endpoint (Get-PureOneArray -ArrayName $arrayname).fqdn -credentials $purecred -DefaultArray -ignoreCertificateError
    #Create Volume, Attach to HostGroup and Provision VMFS Datastore
    New-PfaVmfs -flasharray $faconn -cluster (Get-Cluster $cluster -server $vconn) -volName $dsname -sizeInTB $volcapacityTB
    $faconn = $null
}

$var1,$var5 = Get-P1Datastores
$var2 = Get-P1Load -ArraysToUseName $var1
$var3 = Get-P1LeastLoadArray -ArraysLoad $var2
Deploy-P1DS -LeastLoadArray $var3

#Disconnect VC
Disconnect-VIServer $vcconn -Confirm:$false
#Disconnect Pure1
$global:pureOneRestHeader  = $null
$global:pureOneConnections = $null
