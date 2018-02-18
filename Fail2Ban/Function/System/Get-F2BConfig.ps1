<#
.SYNOPSIS
    Function to get current Configuration
.PARAMETER Name
    .
.EXAMPLE
    C:\PS> Get-F2BConfig -ConfigFolder System
.NOTES
    Author      : Thomas ILLIET
    Date        : 2018-02-15
    Last Update : 2018-02-15
#>
function Get-F2BConfig(){
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('System','Module')]
        [String]$ConfigFolder
    )
    Try {
        $Items = Get-Item "HKLM:\SOFTWARE\Fail2Ban\Config\$ConfigFolder" -ErrorAction Stop
        if($Items.Property -ne $null) {
            $hashtable = @{}
            foreach( $Item in $Items.Property ){
                $hashtable[$Item] = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\Config\$ConfigFolder" -Name $Item)
            }
            return $hashtable
        }
    } Catch {
        write-error "Unable to get configuration : $_"
    }
}