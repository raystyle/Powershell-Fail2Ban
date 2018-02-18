<#
    .NOTES  
        File Name   : Fail2Ban.psm1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Author      : Damien VAN ROBAEYS
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

# +++++++++++++++++++++++++++++
#  Define Variable
$Global:F2BModuleRoot= $PSScriptRoot

# +++++++++++++++++++++++++++++
#  Force Elevation
$CurrentWindowsIdentity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
If ($CurrentWindowsIdentity.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") -eq $false){
    Write-Warning "You do not have Administrator rights to run this module!"
    Write-Warning "Please re-run this module as an Administrator!`n`n"
    break
}

# ++++++++++++++++++++++++
# Show Banner
Write-Host "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Yellow
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++++++++"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++  ++++++`t Fail2Ban Powershell" 
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "+++  +++++"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++  ++++"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++  ++++`t Author  : Thomas ILLIET / Damien VAN ROBAEYS"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "+++  +++++`t Version : V0.0.5"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++      ++"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++++++++"
Write-Host "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Yello
Write-Host "# + " -ForegroundColor Yellow


# ++++++++++++++++++++++++
# Initialization Banner
Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "Initialization"
Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow

# +++++++++++++++++++++++++++++
# Get configuration File
Try {
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Get Config " -nonewline
    $FunctionFile = Get-Content (Join-Path -Path $F2BModuleRoot -ChildPath "Config/Function.json") -ErrorAction Stop
    $Types =  ($FunctionFile | ConvertFrom-Json ).Type
    Write-Host "`t[OK]" -ForegroundColor green
} Catch {
    Write-Error "Unable to get function configuration file : $_"
    break
}

# +++++++++++++++++++++++++++++
# Get Function
Try {
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Get Function " -nonewline
    foreach($Type in $Types) {
        foreach($Function in $Type.Function) {
            . (join-Path -Path $F2BModuleRoot -ChildPath "Function\$($Type.name)\$Function.ps1")
        }
    }
    Write-Host "`t[OK]" -ForegroundColor green
} Catch {
    Write-Error "Unable to load function : $_"
    break
}

# +++++++++++++++++++++++++++++
# Check Update
Try{
    if (Get-Module -ListAvailable -Name 'PowerShellGet') {
        Write-Host "# + " -ForegroundColor Yellow  -nonewline; Write-Host "- Check Update " -nonewline
        if((Get-Module -ListAvailable -Name 'Fail2ban').Version -ge (Find-Module -Name 'Fail2ban').Version) {
            Write-Host "`t[UPDATED]" -ForegroundColor green
        } else {
            Write-Host "`t[OUTDATED]" -ForegroundColor yellow
        }
    } else {
        Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "Unable to check Update, Please install 'PowerShellGet' !" -ForegroundColor red
    }
} Catch {
    Write-error "Unable to Check update for this module !"
}
Write-Host "# + " -ForegroundColor Yellow

# ++++++++++++++++++++++++
# If not installed
if((Test-Path "HKLM:\SOFTWARE\Fail2Ban") -eq $false) {
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "Fail2ban is not installed on this system, please run 'Install-F2B' to install it !" -ForegroundColor Red
    Write-Host "# + " -ForegroundColor Yellow
}

# ++++++++++++++++++++++++
# Show Command List
Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "Command List"
Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host " ____________________________________________________________________________________"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Name               | Category | Description                                        |" 
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "|--------------------|----------|----------------------------------------------------|"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Install-F2B        | Setup    |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Remove-F2B         | Setup    |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Update-F2B         | Setup    |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Disable-F2B        | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Enable-F2B         | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Restart-F2B        | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Start-F2B          | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Stop-F2B           | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Get-F2BStatus      | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Add-F2BAddress     | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Remove-F2BAddress  | Service  |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Set-F2BConfig      | Config   |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Get-F2BConfig      | Config   |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Get-F2BAdmx        | Tool     |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Show-F2BGui        | Tool     |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "| Get-F2BHelp        | Tool     |                                                    |"
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "|____________________________________________________________________________________|"
Write-Host "# + " -ForegroundColor Yellow
Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "If you want more information, please run 'Get-F2BHelp' :)"
Write-Host "# + " -ForegroundColor Yellow
Write-Host "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor yellow


