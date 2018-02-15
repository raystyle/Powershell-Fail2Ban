<#
    .NOTES  
        File Name   : Fail2Ban.psm1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

# +++++++++++++++++++++++++++++
#  Force Elevation
$CurrentWindowsIdentity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
If ($CurrentWindowsIdentity.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") -eq $false){
    Write-Warning "You do not have Administrator rights to run this module!`nPlease re-run this module as an Administrator!"
    break
}

# +++++++++++++++++++++++++++++
#  Define Variable
$Global:F2BModuleRoot= $PSScriptRoot


# +++++++++++++++++++++++++++++
# Get Function
write-debug "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
write-debug "# + Get Function"
write-debug "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

# Get configuration File
Try {
    $FunctionFile = Get-Content (Join-Path -Path $F2BModuleRoot -ChildPath "Config/Function.json") -ErrorAction Stop
    $Types =  ($FunctionFile | ConvertFrom-Json ).Type
} Catch {
    Write-Error "Unable to get function configuration file : $_"
    break
}

# Load function
Try {
    foreach($Type in $Types) {
        write-debug "# - $($Type.name)"
        foreach($Function in $Type.Function) {
            write-debug "#   - $Function"
            . (join-Path -Path $F2BModuleRoot -ChildPath "Function\$($Type.name)\$Function.ps1")
        }
    }
} Catch {
    Write-Error "Unable to load function : $_"
    break
}

write-debug "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"