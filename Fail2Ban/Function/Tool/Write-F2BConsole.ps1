function Write-F2BConsole () {
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('Information','Error','Warning')]
        [String]$Type,
        [Parameter(Mandatory=$true,Position=1)]
        [String]$Message
    )

    $Date = Get-Date -Format "HH:mm:ss.ffffff"

    switch ($Type) {
        Error       { $TypeID = "DarkRed";    $DisplayType = 'ERROR'}
        Warning     { $TypeID = "Yellow"; $DisplayType = 'WARN'}
        Default { $Color = "White";   $DisplayType = 'INFO'}
    }
    Write-Host "# + " -ForegroundColor Yellow -nonewline; write-host "$Date [$DisplayType] - $Message"


}