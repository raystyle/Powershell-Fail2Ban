<#
    .NOTES  
        File Name   : Update-F2B.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Update-F2B(){

    # Update Module
    Write-Debug "# Module update from Powershell Gallery"
    Try {
        Update-Module -Name "Fail2Ban" -Force
    } Catch {
        Write-Error "Unable to update Module : $_"
    }

    # Execute install
}