function Test-F2BFirewallRule(){
    <#
    .SYNOPSIS
        . Verifies a firewall rule according to the input parameters
    .PARAMETER IP
        . IP addresses
    .EXAMPLE
        C:\PS> Test-F2BFirewallRule -IP 1.2.3.4
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
        $CheckFirewallRule = Get-NetFirewallRule -DisplayName "Fail2Ban - Block $IP" -ErrorAction SilentlyContinue
        if($CheckFirewallRule -ne $null) {
            return $true
        } else {
            return $false
        }
    } Catch {
        Write-Error "Unable to Test Firewall Rule : $_"
        return $false
    }
}