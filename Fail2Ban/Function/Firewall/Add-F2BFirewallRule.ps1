<#
    .NOTES  
        File Name   : Add-F2BFirewallRule.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Add-F2BFirewallRule(){
    Param(
        [Parameter(Mandatory=$true)]
        [IpAddress]$IP
    )

    if((Test-F2BFirewallRule -IP $IP) -eq $false) {
        Try {
            $Params = @{
                DisplayName   = "Fail2Ban - Block $IP"
                Direction     = "Inbound"
                RemoteAddress = $IP
                Profile       = "Any"
                Action        = "Block"
            }
            New-NetFirewallRule @PArams -ErrorAction Stop | Out-Null
            Add-F2BLog -Type Information -Category '1' -Message "Add new firewall rule : $IP"
            return $true
        } Catch {
            Add-F2BLog -Type Error -Category '1' -Message "Unable to add a new firewall rule : $_"
            return $false
        }
    } else {
        Add-F2BLog -Type Warning -Category '1' -Message "Firewall Rule already exist : $IP"
        return $false
    }
}