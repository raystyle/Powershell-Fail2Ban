function Add-F2BAddress(){
    <#
    .SYNOPSIS
        .
    .PARAMETER Type
        .
    .PARAMETER IP
        .
    .PARAMETER Unlimited
        .
    .EXAMPLE
        C:\PS> Add-F2BAddress -Type Black -IP 1.2.3.4
        C:\PS> Add-F2BAddress -Type Black -IP 1.2.3.4 -Unlimited $true
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
        [String]$IP,

        [Parameter(Mandatory=$false)]
        [ValidateSet($true,$false)]
        [bool]$Unlimited=$false
    )

    # ++++++++++++++++++++++++
    # Add IP to BlackList
    if($Type -eq 'Black') {
        if((Test-F2BRegistryIP -IP $IP -Type White) -eq $false){
            if((Test-F2BRegistryIP -IP $IP -Type Black) -eq $false){
                Try {
                    Add-F2BRegistryIP -IP $IP -Type Black -Unlimited $Unlimited | Out-Null
                    Add-F2BFirewallRule -IP $IP | Out-Null
                } Catch {
                    Write-Error "Unable to Add IP to BlackList: $_"
                }
            }
        } else {
            Write-Error "Unable to add IP, is present in WhiteList"
        }
    }

    # ++++++++++++++++++++++++
    #  Add IP to WhiteList
    if($Type -eq 'White') {
        if((Test-F2BRegistryIP -IP $IP -Type White) -eq $false){
            # Remove IP if present in BlackList
            if((Test-F2BRegistryIP -IP $IP -Type Black) -eq $true){
                Try {
                    Remove-F2BRegistryIP -IP $IP -Type Black | Out-Null
                    Remove-F2BFirewallRule -IP $IP | Out-Null
                } Catch {
                    Write-Error "Unable to Remove IP to WhiteList: $_"
                }
            }
            # Add to WhiteList
            Try {
                Add-F2BRegistryIP -IP $IP -Type White -Unlimited $Unlimited | Out-Null
            } Catch {
                Write-Error "Unable to Add IP to WhiteList : $_"
            }
        } 
    }
}