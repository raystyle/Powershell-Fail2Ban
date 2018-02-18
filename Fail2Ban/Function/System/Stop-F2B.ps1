function Stop-F2B(){
    <#
    .SYNOPSIS
        Function to Stop Fail2Ban Service
    .EXAMPLE
        C:\PS> Stop-F2B
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    if((Test-F2BScheduledTask -Name 'Fail2Ban-Service') -eq $true) {
        $State = (Get-ScheduledTask -TaskName 'Fail2Ban-Service').State
        if($State -eq 'Running') {
            Try {
                Stop-ScheduledTask -TaskName 'Fail2Ban-Service'
            } Catch {
                Write-Error "Unable to stop Scheduled Task (Fail2Ban-Service)"
            }
        }
    } else {
        Write-Error "Unable to find Scheduled Task (Fail2Ban-Service)"
    }
}