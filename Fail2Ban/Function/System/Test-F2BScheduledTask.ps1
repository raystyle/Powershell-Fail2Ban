<#         
    .NOTES  
        File Name   : Test-F2BScheduledTask.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>
function Test-F2BScheduledTask(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    $ScheduledTask = Get-ScheduledTask -TaskName Fail2ban -ErrorAction SilentlyContinue
    if($ScheduledTask -ne $null) {
        return $true
    } else {
        return $false
    }
}