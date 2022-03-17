#Install the Az module if you haven't done so already.
#Install-Module Az
 
#Login to your Azure account.
#Login-AzAccount

#Select Azure subscription ID
#Select-AzSubscription -Subscription "xxxxxx.xxxxx.xxxx.xxxx"
 
#Define the following parameters for the virtual machine.
$vmAdminUsername = "Enter Username"
$vmAdminPassword = ConvertTo-SecureString "Enterpasswordhere" -AsPlainText -Force
$vmComputerName = "AVD-Gold-01"
 
#Define the following parameters for the Azure resources.
$azureLocation              = "UKSouth"
$azureResourceGroup         = "rg-uks-avd-images"
$vnetResourceGroup         = "rg-uks-avd-network"
$azureVmName                = "$vmComputerName"
$azureVmOsDiskName          = "$vmComputerName-OS"
$azureVmSize                = "Standard_B2s"
 
#Define the networking information.
$azureNicName               = "$vmComputerName-NIC"
#$azurePublicIpName          = "$vmComputerName-IP"
 
#Define the existing VNet information.
$azureVnetName              = "vnet_avd"
$azureVnetSubnetName        = "default"
 
#Define the VM marketplace image details.
$azureVmPublisherName = "MicrosoftWindowsDesktop"
$azureVmOffer = "office-365"
$azureVmSkus = "win10-21h2-avd-m365-g2"
 
#Get the subnet details for the specified virtual network + subnet combination.
$azureVnetSubnet = (Get-AzVirtualNetwork -Name $azureVnetName -ResourceGroupName $vnetResourceGroup).Subnets | Where-Object {$_.Name -eq $azureVnetSubnetName}
 
#Create the public IP address.
#$azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName -ResourceGroupName $azureResourceGroup -Location $azureLocation -AllocationMethod Dynamic
 
#Create the NIC and associate
$azureNIC = New-AzNetworkInterface -Name $azureNicName -ResourceGroupName $azureResourceGroup -Location $azureLocation -SubnetId $azureVnetSubnet.Id
 
#Store the credentials for the local admin account.
$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)
 
#Define the parameters for the new virtual machine.
$VirtualMachine = New-AzVMConfig -VMName $azureVmName -VMSize $azureVmSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $vmComputerName -Credential $vmCredential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $azureNIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $azureVmPublisherName -Offer $azureVmOffer -Skus $azureVmSkus -Version "latest"
$VirtualMachine = Set-AzVMBootDiagnostic -VM $VirtualMachine -Disable
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -StorageAccountType "Premium_LRS" -Caching ReadWrite -Name $azureVmOsDiskName -CreateOption FromImage
 
#Create the virtual machine.
New-AzVM -ResourceGroupName $azureResourceGroup -Location $azureLocation -VM $VirtualMachine -Verbose
