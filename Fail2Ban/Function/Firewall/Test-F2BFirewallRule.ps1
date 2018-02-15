<#
    .NOTES  
        File Name   : Test-F2BFirewallRule.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Test-F2BFirewallRule(){
    Param(
        [Parameter(Mandatory=$true)]
        [IpAddress]$IP
    )

    $Test = Get-NetFirewallRule -DisplayName "Fail2Ban - Block $IP" -ErrorAction SilentlyContinue
    if($Test -ne $null) {
        return $true
    } else {
        return $false
    }
}