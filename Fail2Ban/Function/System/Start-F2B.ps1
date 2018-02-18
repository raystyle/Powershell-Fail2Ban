function Start-F2B () {
    <#
    .SYNOPSIS
        Function to Start Fail2Ban Service
    .EXAMPLE
        C:\PS> Start-F2B
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('Console','Task')]
        [String]$Mode='Task'
    )

    # Check Scheduled Task is exist
    if((Test-F2BScheduledTask -Name 'Fail2Ban-Service') -eq $true) {

        $State = (Get-ScheduledTask -TaskName 'Fail2Ban-Service').State
        if($State -eq 'Ready') {
            if($Mode -eq 'Console'){
                Initialize-F2BService
            } else {
                Start-ScheduledTask -TaskName 'Fail2Ban-Service'
            }
        } else {
            if($State -eq 'Running') {
                Write-Warning "Scheduled Task (Fail2Ban-Service) already Running"
            } elseif ($State -eq 'Disabled') {
                Write-Error "Scheduled Task (Fail2Ban-Service) is Disabled"
            }
        }
        
    } else {
        Write-Error "Unable to find Scheduled Task (Fail2Ban-Service)"
    }
}