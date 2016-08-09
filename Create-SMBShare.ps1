Import-Module NTFSSecurity

#variables
$sharename = "share"
$cachingmode = "none"
$continuouslyavailable = $true
$encryptdata = $false
$folderenumerationmode = "AccessBased"
$path = "D:\Shares\"
$scopename = "Cluster"
$sharepath = $path+$sharename
$fullaccess = "Everyone"


#check if path exists
$PathCheck = Test-Path $sharepath
if ($PathCheck -eq $true) {
    Write-Host "$sharepath exists."
}
else {
    Write-Host "$sharepath does not exist"
    New-Item $sharepath -type directory
}


#create share
New-SmbShare -Name $sharename -CachingMode $cachingmode -ContinuouslyAvailable $continuouslyavailable -EncryptData $encryptdata -FolderEnumerationMode $folderenumerationmode -Path $sharepath -ScopeName $scopename -FullAccess $fullaccess

#disable inheritance and add full access
Disable-NTFSAccessInheritance $sharepath -RemoveInheritedAccessRules
Add-NTFSAccess $sharepath -Account BUILTIN\Administrators -AccessRights FullControl
Get-NTFSAccess $sharepath
