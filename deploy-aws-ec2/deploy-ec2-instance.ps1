if (-not (Get-Module AWSPowerShell)) {
	Import-Module AWSPowerShell -ErrorAction Stop
}

#Variables
$AccessKey = "YOURACCESSKEY"
$SecretAccessKey = "YOURSECRETKEY"
$ProfileName = "YOURCREDENTIALPROFILENAME"
$NameTag = @{ Key="Name"; Value="INSTANCENAME" }
$TagSpec = New-Object Amazon.EC2.Model.TagSpecification
$TagSpec.ResourceType = "instance"
$TagSpec.Tags.Add($NameTag)
$UserDataScript = Get-Content -Raw <PATH TO .TXT WITH SCRIPT TO RUN>
$UserData = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($UserDataScript))

$EC2InstanceDeploymentParameters = @{
    ImageId = "ami-id"
    InstanceType = "t2.micro"
    SecurityGroupId = "sg-id","sg-id2","sg-id3"
    SubnetId = "subnet-id"
    KeyName = "keypair"
    MinCount = "1"
    MaxCount = "1"
    Region = "us-west-2"
    TagSpecification = $TagSpec
    UserData = $UserData
}

#Setup Credential
Set-AWSCredential -AccessKey $AccessKey -SecretAccessKey $SecretAccessKey -StoreAs $ProfileName

#Use Credential
Set-AWSCredential -ProfileName $ProfileName

#Deploy Instance
New-EC2Instance @EC2InstanceDeploymentParameters