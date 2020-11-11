# PowerShell Module for vSphere with Tanzu Workload Management

## Summary

This Module allows you to interact with the VCSA API's to manage vSphere with Tanzu

## Prerequisites

* [PowerCLI](https://code.vmware.com/web/tool/12.0.0/vmware-powercli)

## More Information

[TBD](https://davidstamen.com)

## Create Manifest

$Manifest = @{
    Path = "./VMware.Community.WorkloadManagement.psd1"
    ModuleVersion = "1.0.1"
    Author = "David Stamen"
    CompanyName = "David Stamen"
    PowerShellVersion = "6.0"
    Tags = "VMware"
    ProjectUri = "https://github.com/dstamen/Powershell/tree/master/VMware.Community.WorkloadManagement"
    IconUri = "https://github.com/dstamen/Powershell/raw/master/VMware.Community.WorkloadManagement/tanzu.png"
    Description = "Module for Interacting with VMware vSphere with Tanzu"
    RequiredModules = 'VMware.VimAutomation.Cis.Core'
    FunctionsToExport = 'Get-WorkloadManagementNamespace','Get-WorkloadManagementCluster','Get-WorkloadManagementClusterCompatibility','Get-WorkloadManagementClusterSoftware','Get-WorkloadManagementClusterVersions','Get-WorkloadManagementAuthorizedNamespaces','Get-WorkloadManagementHostsConfig'
}

Update-ModuleManifest @Manifest

