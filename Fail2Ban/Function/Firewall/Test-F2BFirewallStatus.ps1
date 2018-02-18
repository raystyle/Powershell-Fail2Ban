function Test-F2BFirewallStatus(){
    <#
    .SYNOPSIS
        . Verifies a firewall status
    .EXAMPLE
        C:\PS> Test-F2BFirewallStatus
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Try {
        $Interface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Get-NetConnectionProfile
        if($Interface -ne $null) {
            if((Get-NetFirewallProfile  -Name $Interface.NetworkCategory).Enabled -eq $true){
                return $true
            } else {
                return $false
            }
        } else {
            return $false
        }
    } Catch {
        Write-Error "Unable to get interface configuration : $_"
        return $false
    }
}