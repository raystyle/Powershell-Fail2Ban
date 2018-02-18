function Get-F2BAdmx(){
    <#
    .SYNOPSIS
        .
    .PARAMETER Path
        .
    .EXAMPLE
        C:\PS> Get-F2BAdmx -Path c:\tmp\
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Path
    )

    write-host "Comming soon !!!"
    break
    
    if((Test-Path $Path) -eq $true) {
        try {
            Copy-Item -Path (Join-Path -Path $F2BModuleRoot -ChildPath 'Admx') -Destination $Path -Recurse -Force -ErrorAction Stop
        } Catch {
            Write-Error "Unable to Copy Admx folder : $_"
        }
    } else {
        write-error "Unable to find folder : $_"
    }
}