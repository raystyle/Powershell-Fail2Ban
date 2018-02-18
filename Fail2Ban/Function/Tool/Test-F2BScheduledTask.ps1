function Test-F2BScheduledTask(){
    <#
    .SYNOPSIS
        Function to check that the scheduled task exists
    .PARAMETER Name
        Specifies names of a scheduled task.
    .EXAMPLE
        C:\PS> Test-F2BScheduledTask -Name "MyScheduledTask"
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    $ScheduledTask = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if($ScheduledTask -ne $null) {
        return $true
    } else {
        return $false
    }
}