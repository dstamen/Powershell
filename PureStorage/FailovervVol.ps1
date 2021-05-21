
$vc1 =  Connect-VIServer "vc01.lab.local" -WarningAction SilentlyContinue
$vc2 =  Connect-VIServer "vc02.lab.local" -WarningAction SilentlyContinue

#failover
$vm = get-vm -name "vvol01" -server $vc1
$sourceGroup = $vm | Get-SpbmReplicationGroup -server $vc1

$targetPair = get-spbmreplicationpair -source $sourceGroup
$syncgroup = $targetPair.Target.Name
Sync-SpbmReplicationGroup -ReplicationGroup $syncgroup -PointInTimeReplicaName 'Sync-Powered-On-VM'
Stop-VM -VM $vm -Confirm:$false
Sync-SpbmReplicationGroup -ReplicationGroup $syncgroup -PointInTimeReplicaName 'Sync-Powered-Off-VM'
$targetGroup = $targetPair.Target

Start-SpbmReplicationPrepareFailover -ReplicationGroup $sourceGroup
$testVms = Start-SpbmReplicationFailover -ReplicationGroup $targetGroup -Confirm:$false

new-vm -VMFilePath $testVms -ResourcePool "destination-cluster" -Server $vc2
$newvm = get-vm -name "vvol01" -Server $vc2
$newvm | Get-VMQuestion | Set-VMQuestion –DefaultOption -Confirm:$false

$new_source_group = Start-SpbmReplicationReverse -ReplicationGroup $targetGroup
$HD1 = $newvm | Get-HardDisk
$newvm_policy_1 = $newvm, $HD1 | Get-SpbmEntityConfiguration
$newvm_policy_1 | Set-SpbmEntityConfiguration -StoragePolicy "VVol No Requirements Policy" -Server $vc2
$policy_1 = Get-SpbmStoragePolicy -Server $vc2 -name "app01"
$new_rg = $policy_1 | Get-SpbmReplicationGroup -Server $vc2 -Name "destarray:r-app01*"
$newvm_policy_1 | Set-SpbmEntityConfiguration -StoragePolicy $policy_1 -ReplicationGroup $new_rg
$newvm | Start-VM -confirm:$false
$newvm | Get-VMQuestion | Set-VMQuestion –DefaultOption -Confirm:$false
$vm|Remove-VM -DeletePermanently -Confirm:$false

############################################################################################################################################
############################################################################################################################################
############################################################################################################################################
############################################################################################################################################

#failback
$vm = get-vm -name "vvol01" -server $vc2
$sourceGroup = $vm | Get-SpbmReplicationGroup -server $vc2

$targetPair = get-spbmreplicationpair -source $sourceGroup
$syncgroup = $targetPair.Target.Name
Sync-SpbmReplicationGroup -ReplicationGroup $syncgroup -PointInTimeReplicaName 'Sync-Powered-On-VM'
Stop-VM -VM $vm -Confirm:$false
Sync-SpbmReplicationGroup -ReplicationGroup $syncgroup -PointInTimeReplicaName 'Sync-Powered-Off-VM'
$targetGroup = $targetPair.Target

Start-SpbmReplicationPrepareFailover -ReplicationGroup $sourceGroup
$testVms = Start-SpbmReplicationFailover -ReplicationGroup $targetGroup -Confirm:$false

new-vm -VMFilePath $testVms -ResourcePool "source-cluster" -Server $vc1
$newvm = get-vm -name "vvol01" -Server $vc1
$newvm | Get-VMQuestion | Set-VMQuestion –DefaultOption -Confirm:$false

$new_source_group = Start-SpbmReplicationReverse -ReplicationGroup $targetGroup
$HD1 = $newvm | Get-HardDisk
$newvm_policy_1 = $newvm, $HD1 | Get-SpbmEntityConfiguration
$newvm_policy_1 | Set-SpbmEntityConfiguration -StoragePolicy "VVol No Requirements Policy" -Server $vc1
$policy_1 = Get-SpbmStoragePolicy -Server $vc1 -name "app01"
$new_rg = $policy_1 | Get-SpbmReplicationGroup -Server $vc1 -Name "sourcearray:app01*"
$newvm_policy_1 | Set-SpbmEntityConfiguration -StoragePolicy $policy_1 -ReplicationGroup $new_rg
$newvm | Start-VM -confirm:$false
$newvm | Get-VMQuestion | Set-VMQuestion –DefaultOption -Confirm:$false
$vm|Remove-VM -DeletePermanently -Confirm:$false
