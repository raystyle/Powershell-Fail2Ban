<#
    .NOTES  
        File Name   : Add-F2BLog.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

    # ++++++++++++++++++++++++++
    # + Add Event Log
function Add-F2BLog(){
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Information','Error','Warning')]
        [String]$Type,
        [Parameter(Mandatory=$true)]
        [String]$Message,
        [Parameter(Mandatory=$false)]
        [String]$Category='System',
        [Parameter(Mandatory=$false)]
        [Object]$Config
    )

    # Get configuration
    if($Config -eq $null) {
        $Config = Get-F2BConfig
    }

    # -------------
    # Windows Log
    if($Config.EventLog_Enabled -eq "True") {
        $Params = @{
            LogName   = $Config.EventLog_Name
            Source    = "Fail2Ban"
            EntryType = $Type
            EventId   = $Config.EventLog_Id
            Message   = $Message
            Category  = $Category
        }
        Write-EventLog @Params
    }

    # -------------
    # console
}