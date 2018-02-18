function Remove-F2BFirewallRule(){
    <#
    .SYNOPSIS
        . Remove a new inbound firewall rule
    .PARAMETER IP
        . IP addresses
    .EXAMPLE
        C:\PS> Remove-F2BFirewallRule -IP 1.2.3.4
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [IpAddress]$IP
    )
    Try {
        $RuleName = "Fail2Ban - Block $IP"
        Remove-NetFirewallRule -DisplayName $RuleName
        return $true
    } Catch {
        Write-error "Unable to remove a firewall rule ($RuleName)"
        return $false
    }

}