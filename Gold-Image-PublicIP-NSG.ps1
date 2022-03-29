#Install the Az module if you haven't done so already.
#Install-Module Az
 
#Login to your Azure account.
Login-AzAccount

#Select Azure subscription ID
Select-AzSubscription -Subscription "b307cf18-be83-48b5-aad4-899e579070b9"
 
#Define the following parameters for the virtual machine.
$vmAdminUsername = Read-Host -Prompt "Enter"
$vmAdminPassword = ConvertTo-SecureString "MondaySunny2022!" -AsPlainText -Force
$vmComputerName = "AVD-Cloud-04"
 
#Define the following parameters for the Azure resources.
$azureLocation              = "UKSouth"
$azureResourceGroup         = "rg-uks-avd-images"
$vnetResourceGroup         = "rg-uks-avd-network"
$azureVmName                = "$vmComputerName"
$azureVmOsDiskName          = "$vmComputerName"
$azureVmSize                = "Standard_B2ms"
$nsgname                    = "avd-uks-nsg"
$nsgResourceGroup           = "rg-uks-avd-network"
 
#Define the networking information.
$azureNicName               = "$vmComputerName-NIC"
#$azurePublicIpName          = "$vmComputerName-IP"
 
#Define the existing VNet information.
$azureVnetName              = "vnet_avd"
$azureVnetSubnetName        = "default"
 
#Multi Session Host Office 365 image details.
#$azureVmPublisherName = "MicrosoftWindowsDesktop"
#$azureVmOffer = "office-365"
#$azureVmSkus = "win10-21h2-avd-m365-g2"

#Windows 365 Enterprise – Cloud PC.
$azureVmPublisherName = "MicrosoftWindowsDesktop"
$azureVmOffer = "windows-ent-cpc"
$azureVmSkus = "win11-21h2-ent-cpc-m365"
 
#Get the subnet details for the specified virtual network + subnet combination.
$azureVnetSubnet = (Get-AzVirtualNetwork -Name $azureVnetName -ResourceGroupName $vnetResourceGroup).Subnets | Where-Object {$_.Name -eq $azureVnetSubnetName}

#Create the public IP address.
#$azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName -ResourceGroupName $azureResourceGroup -Location $azureLocation -AllocationMethod Dynamic
 
#Create the NIC and associate the public IpAddress.
$azureNIC = New-AzNetworkInterface -Name $azureNicName -ResourceGroupName $azureResourceGroup -Location $azureLocation -SubnetId $azureVnetSubnet.Id #-PublicIpAddressId $azurePublicIp.Id
 
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
New-AzVM -ResourceGroupName $azureResourceGroup -Location $azureLocation -VM $VirtualMachine -DisableBginfoExtension -Verbose

#Assign NSG
#$NSG = Get-AzNetworkSecurityGroup -Name "$nsgname" -ResourceGroupName "$nsgResourceGroup"
#$NIC = Get-AzNetworkInterface -name "$azureVmName-NIC" 
#$NIC.NetworkSecurityGroup = $NSG
#$NIC | Set-AzNetworkInterface


