<#
    .NOTES  
        File Name   : Get-F2BFirewallRule.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Get-F2BFirewallRule(){

    $Data = Get-NetFirewallRule -DisplayName "Fail2Ban - Block *" -ErrorAction SilentlyContinue
    if($Data -ne $null) {
        return $Data
    }

}