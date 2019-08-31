#!/usr/bin/pwsh

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

#Generelle Variabler 
$rg = "opgave1"
$location = "NorthEurope"
$vnetname = "opgave1-vnet"
$vnetaddr = "10.0.0.0/21"

#Subnet variabler
$subAname = "subnetA"
$subBname = "subnetB"
$subCname = "subnetC"
$subDname = "subnetD"

$subAadr = "10.0.1.0/24"
$subBadr = "10.0.2.0/24"
$subCadr = "10.0.3.0/24"
$subDadr = "10.0.4.0/24"

#De faerdige subnet variabler
$subA = New-AzVirtualNetworkSubnetConfig -name $subAname -addressprefix $subAadr
$subB = New-AzVirtualNetworkSubnetConfig -name $subBname -addressprefix $subBadr
$subC = New-AzVirtualNetworkSubnetConfig -name $subCname -addressprefix $subCadr
$subD = New-AzVirtualNetworkSubnetConfig -name $subDname -addressprefix $subDadr

#Resourcegruppen laves
New-AzResourceGroup -name $rg -location $location

#Vnet laves med alle subnets
New-AzVirtualNetwork -name $vnetname -ResourceGroupName $rg -location $location -AddressPrefix $vnetaddr -Subnet $subA,$subB,$subC,$subD


