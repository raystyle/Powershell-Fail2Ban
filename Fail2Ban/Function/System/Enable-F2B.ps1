<#         
    .NOTES  
        File Name   : Enable-F2B.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Enable-F2B(){

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