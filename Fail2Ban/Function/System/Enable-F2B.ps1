function Enable-F2B(){
    <#
    .SYNOPSIS
        .
    .EXAMPLE
        C:\PS> Enable-F2B
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    
    Write-Debug "# Enable Fail2ban"

    $Task = Get-ScheduledTask -TaskName Fail2ban -ErrorAction SilentlyContinue
    if($Task -ne $null) {
        if($Task.State -eq 'Disabled'){
            Try {
                Disable-ScheduledTask -TaskName Fail2ban
                return $true
            } Catch {
                Write-Error "Unable to disable Fail2ban scheduled task : $_"
                return $false
            }
        } else {
            if($Task.State -eq 'Ready'){
                write-debug ""
                return $true
            } else {
                Write-Error ""
                return $false
            }
        }
    } else {
        Write-Error ""
        return $false
    }

}