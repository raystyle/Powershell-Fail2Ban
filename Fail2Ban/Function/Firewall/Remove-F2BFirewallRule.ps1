<#
    .NOTES  
        File Name   : Enable-F2B.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Remove-F2BFirewallRule(){
    Param(
        [Parameter(Mandatory=$true)]
        [IpAddress]$IP
    )

    if((Test-F2BFirewallRule -IP $IP) -eq $true) {
        Try {
            Remove-NetFirewallRule -DisplayName "Fail2Ban - Block $IP"
            Add-F2BLog -Type Information -Category '2' -Message "Remove firewall rule : $IP"
            return $true
        } Catch {
            Add-F2BLog -Type Error -Category '2' -Message "Unable to remove a firewall rule : $IP"
            return $false
        }
    } else {
        Add-F2BLog -Type Warning -Category '2' -Message "Firewall Rule isn't exists : $IP"
        return $false
    }
}