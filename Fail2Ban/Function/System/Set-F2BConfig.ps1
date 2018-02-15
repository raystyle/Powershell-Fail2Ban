<#         
    .NOTES  
        File Name   : Set-F2BConfig.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

    function Set-F2BConfig(){
        Param(
            [Parameter(Mandatory=$true)]
            [String]$Name,
            [Parameter(Mandatory=$true)]
            [String]$Value
        )
        if(((Get-F2BConfig).($Name)) -ne $null) {
            Try {
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config" -Name $Name -Value $Value
            } Catch {
                write-error "unable to set Config value"
            }
        } else {
            Write-Host "Config Not found"
        }
    }