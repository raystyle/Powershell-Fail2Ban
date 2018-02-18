function Set-F2BConfig(){
    <#
    .SYNOPSIS
        Function to check that the scheduled task exists
    .PARAMETER ConfigFolder
        .
    .PARAMETER Name
        .
    .PARAMETER Value
        .
    .EXAMPLE
        C:\PS> Set-F2BConfig -ConfigFolder System -Name "ConfigName" -Value "Unicorne"
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('System','Module')]
        [String]$ConfigFolder,
        [Parameter(Mandatory=$true,Position=1)]
        [String]$Name,
        [Parameter(Mandatory=$true,Position=2)]
        [String]$Value
    )

    if(((Get-F2BConfig -ConfigFolder $ConfigFolder).($Name)) -ne $null) {
        Try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\$ConfigFolder" -Name $Name -Value $Value
        } Catch {
            write-error "Unable to set Property value : $_"
        }
    } else {
        write-error "Unable to set Property : $_"
    }
}