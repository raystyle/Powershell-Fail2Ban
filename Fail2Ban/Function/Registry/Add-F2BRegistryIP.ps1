<#
    .NOTES  
        File Name   : Add-F2BRegistryIP.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

Function Add-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type,

        [Parameter(Mandatory=$false)]
        [ValidateSet($true,$false)]
        [bool]$Unlimited=$false
    )

    # If not Exist
    if((Test-F2BRegistryIP -IP $IP -Type $Type) -eq $false) {

        # Set Duration
        if($Unlimited -eq $true) {
            $Value = 'Unlimited'
        } else {
            $Value = ([String](Get-Date))
        }

        # Add IP
        Try {
            New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $IP -Value $Value -PropertyType "String"
            Add-F2BLog -Type Information -Category '3' -Message "Add new IP in $($Type)List : $IP"
            return $true
        } Catch {
            Add-F2BLog -Type Error -Category '3' -Message "Unable to add a new IP in $($Type)List : $IP"
            return $false
        }
    } else {
        Add-F2BLog -Type Warning -Category '3' -Message "This IP in $($Type)List already exists: $IP"
        return $false
    }
}