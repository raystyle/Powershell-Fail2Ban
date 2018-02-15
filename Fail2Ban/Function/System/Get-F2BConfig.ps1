<#         
    .NOTES  
        File Name   : Get-F2BConfig.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Get-F2BConfig(){
    $Items = (Get-Item "HKLM:\SOFTWARE\Fail2Ban\Config").Property
    $hashtable = @{}
    foreach( $Item in $Items ){
        $hashtable[$Item] = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\Config" -Name $Item)
    }
    return $hashtable
}