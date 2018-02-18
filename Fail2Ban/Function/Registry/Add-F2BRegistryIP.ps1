Function Add-F2BRegistryIP(){
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
        C:\PS> Add-F2BRegistryIP -Type Black -IP 5.6.7.8 
        C:\PS> Add-F2BRegistryIP -Type Black -IP 5.6.7.8 -Unlimited $true
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
        [IpAddress]$IP,
        [Parameter(Mandatory=$false,Position=2)]
        [ValidateSet($true,$false)]
        [bool]$Unlimited=$false
    )
    # Add IP to registry
    Try {

        # Set Duration
        if($Unlimited -eq $true) {
            $Value = 'Unlimited'
        } else {
            $Value = ([String](Get-Date))
        }

        $NewItem = New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $IP -Value $Value -PropertyType "String"
        Add-F2BLog -Type Information -Message "Add registry $IP to $($Type)List"
        return $NewItem
    } Catch {
        $Message = "Unable to add a registry '$IP' to $($Type)List"
        Add-F2BLog -Type Error -Message $Message 
        return $false
    }

}