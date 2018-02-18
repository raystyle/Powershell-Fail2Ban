function Restart-F2B (){
    <#
    .SYNOPSIS
        Function to Restart Fail2Ban Service
    .EXAMPLE
        C:\PS> Restart-F2B
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>
    Try {
        Stop-F2B
        Start-F2B
    } Catch {
        write-error "Unable to restart Fail2ban Service"
    }
}