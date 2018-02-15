<#
    .NOTES  
        File Name   : Get-F2BMatch.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Get-F2BMatch(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Patern,
        [Parameter(Mandatory=$true)]
        [String]$Data
    )

    $Content = $Data | Find-Matches -Pattern $Patern
    if($content.Count -eq 2) {
        $Match = $content[1]
    } else {
        $Match =  $content
    }
    $Match = (($Match -split ":")[1]) -replace "\s+",""

    return $Match
}