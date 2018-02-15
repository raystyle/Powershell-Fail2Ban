<#
    .NOTES  
        File Name   : Test-F2BRegistryIP.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

Function Test-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type
    )
    $Data = (Get-Item HKLM:\SOFTWARE\Fail2Ban\List\$Type\).Property
    if($Data -ne $null) {
        if($Data.Contains($IP)) {
            return $true
        } else {
            return $false
        }
    } else {
        return $false
    }
}