<#
    .NOTES  
        File Name   : Get-F2BRegistryIP.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

Function Get-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type
    )
    $Items = (Get-Item "HKLM:\SOFTWARE\Fail2Ban\List\$Type").Property

    $hashtable = @{}
    foreach( $Item in $Items ){
        $hashtable[$Item] = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $Item)
    }
    return $hashtable
}