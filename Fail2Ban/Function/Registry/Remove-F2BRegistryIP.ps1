<#
    .NOTES  
        File Name   : Remove-F2BRegistryIP.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

Function Remove-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type
    )

    if((Test-F2BRegistryIP -IP $IP -Type $Type) -eq $true) {
        Try {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $IP
            Add-F2BLog -Type Information -Category '4' -Message "Remove IP in $($Type)List : $IP"
            return $true
        } Catch {
            Add-F2BLog -Type Error -Category '4' -Message "Unable to remove IP in $($Type)List : $IP"
            return $false
        }
    } else {
        Add-F2BLog -Type Warning -Category '4' -Message "IP isn't isn't exists in $($Type)List : $IP"
        return $false
    }
}