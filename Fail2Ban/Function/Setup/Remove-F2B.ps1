<#
    .NOTES  
        File Name   : Enable-F2B.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Remove-F2B(){
    
    Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "Fail2Ban Remove"
    Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow

    Write-Host "# + " -ForegroundColor Yellow -nonewline;
    $Choice = Read-Host 'Do you really want to delete all data [yes/NO] '

    if($Choice -eq "yes") {
        
        # Stop Fail2ban
        Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Stop Service"
        Stop-F2B

        # Remove Folder
        Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Remove Folder"
        Try {
            Remove-Item -Path "$($env:PROGRAMFILES)\Fail2Ban" -Recurse -Force -ErrorAction Stop
        } Catch {
            Write-Error "Unable to remove properly this folder : $_"
        }

        # Remove Registry Key
        Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Remove Registry Key"
        Try {
            Remove-Item -Path "HKLM:\SOFTWARE\Fail2Ban\" -Recurse -Force -ErrorAction Stop
        } Catch {
            Write-Error "Unable to remove properly this registry Key : $_"
        }

        # Remove scheduled Task
        Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Remove scheduled Task"
        Try {
            Unregister-ScheduledTask -TaskName "Fail2Ban-Service" -Confirm:$false
            Unregister-ScheduledTask -TaskName "Fail2Ban-Manager" -Confirm:$false
        } Catch {
            write-error "Unable to Remove scheduled Task"
        }

    } else {
        Write-Output "Operation canceled"
    }

    Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow
}