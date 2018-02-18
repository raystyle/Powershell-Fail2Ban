function Get-F2BStatus(){
    <#
    .SYNOPSIS
    Function to get the fail2ban service status
    .EXAMPLE
        C:\PS> Get-F2BStatus
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    
    if((Test-F2BScheduledTask -Name 'Fail2Ban-Service') -eq $true) {
        $State = (Get-ScheduledTask -TaskName 'Fail2Ban-Service').State
        write-host $State
    } else {
        Write-Error "Unable to find Scheduled Task (Fail2Ban-Service)"
    }
}