$arrayendpoint = "fa.lab.local"
$srcprotectiongroup = "srcflasharray:app01"
$srcvolumename = "vvol-vvol01-0-1-f8197240-vg/Data-108a7077"
$pureuser = "pureuser"
$purepass = ConvertTo-SecureString "pureuser" -AsPlainText -Force
$purecred = New-Object System.Management.Automation.PSCredential -ArgumentList ($pureuser, $purepass)
$vcuser = "administrator@vsphere.local"
$vcpass = "Password1!"
$vcname = "vc.lab.local"
$vm = "VM01"
$vvolds = "dstflasharray-vvol"

# Connect to and set the active Pure Storage FlashArray
$array = New-PfaConnection -endpoint $arrayendpoint -credentials $purecred -defaultArray -ignoreCertificateError

# Connect to vCenter Server
$vcenter = Connect-VIServer $vcname -User $vcuser -Password $vcpass -WarningAction SilentlyContinue

#Get Most Recent Completed Snapshot
Write-Host "Obtaining the most recent snapshot for the protection group..." -ForegroundColor Red
$MostRecentSnapshots = Get-PfaProtectionGroupSnapshots -Array $array -Name $srcprotectiongroup | Sort-Object created -Descending | Select-Object -Property name -First 2

# Check that the last snapshot has been fully replicated
$FirstSnapStatus = Get-PfaProtectionGroupSnapshotReplicationStatus -Array $array -Name $MostRecentSnapshots[0].name

# If the latest snapshot's completed property is null, then it hasn't been fully replicated - the previous snapshot is good, though
if ($null -ne $FirstSnapStatus.completed) {
    $MostRecentSnapshot = $MostRecentSnapshots[0].name
}
else {
    $MostRecentSnapshot = $MostRecentSnapshots[1].name
}

# Get Size of Source Disk
$VolSize = ((Get-PfaVolumeSnapshot -Array $array -SnapshotName ($MostRecentSnapshot + '.' + $srcvolumename)).size  / 1024 / 1024 / 1024)

#Get VM
$vm = Get-VM -Name $vm

#Create Hard Disk
$disk = New-HardDisk -CapacityGB $VolSize -Datastore $vvolds -VM $vm
$vvoluuid = $disk|Get-VvolUuidFromHardDisk
$destvvol =  Get-PfaVolumeNameFromVvolUuid -VvolUUID $vvoluuid

# Overwrite Dest vvVol with SnapshotOffline the Disk
Write-Host "Overwriting the volume with a copy of the most recent snapshot..." -ForegroundColor Red
New-PfaVolume -Array $array -VolumeName $destvvol -Source ($MostRecentSnapshot + '.' + $srcvolumename) -Overwrite | Out-Null
