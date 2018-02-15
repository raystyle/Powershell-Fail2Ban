<#         
    .NOTES  
        File Name   : Get-F2BEventLog.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Get-F2BEventLog(){

    $Config = Get-F2BConfig
    $CheckTime = ($Config | Where-Object { $_.Name -eq 'CheckTime'}).value

    $AfterDate = (Get-Date).AddSeconds(-$CheckTime)
    $EventLogs = Get-EventLog -log Security -After $AfterDate -InstanceId 4625

    $Obj = @()
    foreach($EventLog in $EventLogs) {
        
        $Return = [PSCustomObject]@{
            Index    = $EventLog.Index
            Time     = $EventLog.TimeWritten
            Type     = $EventLog.EntryType
            Username = Get-Match -Patern "account name:\s+\w+" -Data $EventLog.message
            IP       = Get-Match -Patern "Source Network Address:\s+\d{1,3}(\.\d{1,3}){3}" -Data $EventLog.message
        }

        $Obj += $Return
    }

    Return $Obj
}