function Remove-F2BAddress(){
    <#
    .SYNOPSIS
        .
    .PARAMETER Type
        .
    .PARAMETER IP
        .
    .EXAMPLE
        C:\PS> Remove-F2BAddress -Type Black -IP 1.2.3.4
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
        [String]$IP
    )

    if((Test-F2BRegistryIP -IP $IP -Type $Type) -eq $true){
        Try {
            if($Type -eq 'Black') {
                Remove-F2BRegistryIP -IP $IP -Type Black
                Remove-F2BFirewallRule -IP $IP
            }

            if($Type -eq 'White') {
                Remove-F2BRegistryIP -IP $IP -Type White
            }
        } Catch {
            Write-Error "Unable to Remove IP : $_"
        }
    } else {
        Write-Error "Unable to Find IP"
    }
}