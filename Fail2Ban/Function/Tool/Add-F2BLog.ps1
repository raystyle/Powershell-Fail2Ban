function Add-F2BLog(){
    <#
    .SYNOPSIS
        .
    .PARAMETER Type
        .
    .PARAMETER Message
        .
    .PARAMETER Category
        .
    .EXAMPLE
        C:\PS> Add-F2BLog -Type Error -Message 'My Unicorn is beatifull'
        C:\PS> Add-F2BLog -Type Error -Message 'My Unicorn is beatifull'
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('Information','Error','Warning')]
        [String]$Type,
        [Parameter(Mandatory=$true,Position=1)]
        [String]$Message
    )

    # ++++++++++++++++++++++++
    # Get Configuration
    $Config = Get-F2BConfig -ConfigFolder System

    # ++++++++++++++++++++++++
    # File Log
    if($Config.FileLog_Status -eq "1") {
        Try {
            $Time = Get-Date -Format "HH:mm:ss.ffffff"
            $Date = Get-Date -Format "MM-dd-yyyy"
            $FilePath = (join-path -Path $Config.FileLog_Folder -ChildPath "Fail2Ban-Service.log")

            switch ($Type) {
                Information { $TypeID = 1 }
                Error       { $TypeID = 3 }
                Warning     { $TypeID = 2 }
            }

            $LogMessage = "<![LOG[$Message" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"`" context=`"`" type=`"$TypeID`" thread=`"`" file=`"`">"
            $LogMessage | Out-File -Append -Encoding UTF8 -FilePath $FilePath
        } Catch {
            write-error "Unable to write File : $_"
        }
    }

    # ++++++++++++++++++++++++
    # Windows Log
    if($Config.EventLog_Status -eq "1") {
        Try {
            $Params = @{
                LogName   = $Config.EventLog_Name
                Source    = "Fail2Ban"
                EntryType = $Type
                EventId   = $Config.EventLog_Id
                Message   = $Message
            }
            Write-EventLog @Params
        } Catch {
            write-error "Unable to write EventLog : $_"
        }
    }
}