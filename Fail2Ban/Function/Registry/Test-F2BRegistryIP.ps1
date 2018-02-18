Function Test-F2BRegistryIP(){
    <#
    .SYNOPSIS
        .
    .PARAMETER Type
        .
    .PARAMETER IP
        .
    .EXAMPLE
        C:\PS> Test-F2BRegistryIP -Type Black -IP 1.2.3.4
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('Black','White')]
        [String]$Type,
        [Parameter(Mandatory=$true,Position=1)]
        [IpAddress]$IP
    )

    $Data = (Get-Item HKLM:\SOFTWARE\Fail2Ban\List\$Type).Property
    if($Data -ne $null) {
        if($Data -contains $IP) {
            return $true
        } else {
            return $false
        }
    } else {
        return $false
    }
}