<#         
    .NOTES  
        File Name   : Get-F2BAdmx.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Get-F2BAdmx(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Path
    )

    if(Test-Path $Path -eq $true) {
        try {
            Copy-Item -Path (Join-Path -Path $F2BModuleRoot -ChildPath 'Admx') -Destination $Path -Recurse -Force -ErrorAction Stop
        } Catch {
            Write-Error "Unable to Copy Admx folder : $_"
        }
    } else {
        write-error "Unable to find folder : $_"
    }
}