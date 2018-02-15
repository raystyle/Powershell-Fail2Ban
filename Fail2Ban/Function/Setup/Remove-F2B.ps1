<#
    .NOTES  
        File Name   : Enable-F2B.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Remove-F2B(){
    
    write-debug "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    write-debug "# + Remove Fail2ban"
    write-debug "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

    $Choice = Read-Host 'Do you really want to delete all data [yes/NO] '

    if($Choice -eq "yes") {
        
        # Stop Fail2ban
        Write-debug "# Stop Fail2ban"
        Stop-F2B

        # Remove Folder
        Write-Debug "# Remove Folder"
        Try {
            Remove-Item -Path "$($env:PROGRAMFILES)\Fail2Ban" -Recurse -Force -ErrorAction Stop
        } Catch {
            Write-Error "Unable to remove properly this folder : $_"
        }

        # Remove Registry Key
        Write-Debug "# Remove Registry Key"
        Try {
            Remove-Item -Path "HKLM:\SOFTWARE\Fail2Ban\" -Recurse -Force -ErrorAction Stop
        } Catch {
            Write-Error "Unable to remove properly this registry Key : $_"
        }

        # Remove scheduled Task
        Write-Debug "# Remove scheduled Task"
        Try {
            Unregister-ScheduledTask -TaskName "Fail2Ban-Service" -Confirm:$false
            Unregister-ScheduledTask -TaskName "Fail2Ban-Manager" -Confirm:$false
        } Catch {
            write-error "Unable to Remove scheduled Task"
        }

    } else {
        Write-Output "Operation canceled"
    }

    write-debug "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

}