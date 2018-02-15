<#
    .NOTES  
        File Name   : Test-F2BFirewallStatus.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Test-F2BFirewallStatus(){
    $Interface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Get-NetConnectionProfile
    if($Interface -ne $null) {
        if((Get-NetFirewallProfile  -Name $Interface.NetworkCategory).Enabled -eq $true){
            return $true
        } else {
            return $false
        }
    } else {
        return $false
    }
}