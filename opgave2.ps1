#!/usr/bin/pwsh

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

#Variabler
$rg = "opgave2"
$location = "NorthEurope"

#Resourcegruppe laves
New-AzResourceGroup -ResourceGroupName $rg -Location $location

#Routing table
$routeTablePublic = New-AzRouteTable `
  -Name 'Opg2RouteTablePublic' `
  -ResourceGroupName $rg `
  -location $location

Get-AzRouteTable `
  -ResourceGroupName $rg `
  -Name "Opg2RouteTablePublic" `
  | Add-AzRouteConfig `
  -Name "ToPrivateSubnet" `
  -AddressPrefix 10.0.1.0/24 `
  -NextHopType "VirtualAppliance" `
  -NextHopIpAddress 10.0.2.4 `
  | Set-AzRouteTable

#Vnet konfigureres
$virtualNetwork = New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location $location `
  -Name "Opg2VirtualNetwork" `
  -AddressPrefix 10.0.0.0/16

#subnet laves
$subnetConfigPublic = Add-AzVirtualNetworkSubnetConfig `
  -Name Public `
  -AddressPrefix 10.0.0.0/24 `
  -VirtualNetwork $virtualNetwork

$subnetConfigPrivate = Add-AzVirtualNetworkSubnetConfig `
  -Name Private `
  -AddressPrefix 10.0.1.0/24 `
  -VirtualNetwork $virtualNetwork

$subnetConfigDmz = Add-AzVirtualNetworkSubnetConfig `
  -Name DMZ `
  -AddressPrefix 10.0.2.0/24 `
  -VirtualNetwork $virtualNetwork

$virtualNetwork | Set-AzVirtualNetwork

Set-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $virtualNetwork `
  -Name 'Public' `
  -AddressPrefix 10.0.0.0/24 `
  -RouteTable $routeTablePublic | `
Set-AzVirtualNetwork

# Retrieve the virtual network object into a variable.
$virtualNetwork=Get-AzVirtualNetwork `
  -Name "Opg2VirtualNetwork" `
  -ResourceGroupName $rg

# Retrieve the subnet configuration into a variable.
$subnetConfigDmz = Get-AzVirtualNetworkSubnetConfig `
  -Name DMZ `
  -VirtualNetwork $virtualNetwork

# Create the network interface.
$nic = New-AzNetworkInterface `
  -ResourceGroupName $rg `
  -Location $location `
  -Name 'Opg2VmNva' `
  -SubnetId $subnetConfigDmz.Id `
  -EnableIPForwarding

# Create a credential object.
$cred = Get-Credential -Message "Enter a username and password for the VM."

# Create a VM configuration.
$vmConfig = New-AzVMConfig `
  -VMName 'Opg2VmNva' `
  -VMSize "Standard_D1_v2" | `
  Set-AzVMOperatingSystem -Windows `
    -ComputerName 'Opg2VmNva' `
    -Credential $cred | `
  Set-AzVMSourceImage `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2016-Datacenter `
    -Version latest | `
  Add-AzVMNetworkInterface -Id $nic.Id

New-AzVM `
  -ResourceGroupName $rg `
  -Location $location `
  -VM $vmConfig

New-AzVm `
  -ResourceGroupName $rg `
  -Location $location `
  -VirtualNetworkName "Opg2VirtualNetwork" `
  -SubnetName "Public" `
  -ImageName "Win2016Datacenter" `
  -Name "Opg2VmPublic"
  -Credential $cred

New-AzVm `
  -ResourceGroupName $rg `
  -Location $location `
  -VirtualNetworkName "Opg2VirtualNetwork" `
  -SubnetName "Private" `
  -ImageName "Win2016Datacenter" `
  -Name "Opg2VmPrivate"
  -Credential $cred