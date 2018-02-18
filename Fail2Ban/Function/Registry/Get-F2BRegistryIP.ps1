Function Get-F2BRegistryIP(){
    <#
    .SYNOPSIS
        .
    .PARAMETER Type
        .
    .EXAMPLE
        C:\PS> AGet-F2BRegistryIP -Type Black
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
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