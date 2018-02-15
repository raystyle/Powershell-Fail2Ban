<#         
    .NOTES  
        File Name   : Start-F2B.ps1
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.0
#>

function Start-F2B () {
    if((Test-F2BScheduledTask -Name 'Fail2Ban-Service') -eq $true) {
        $State = (Get-ScheduledTask -TaskName 'Fail2ban-Service').State
        if($State -eq 'Ready') {
            # Start
            Start-ScheduledTask -TaskName 'Fail2Ban-Service'

            # Wait and See
            Start-Sleep -Seconds '5'
            $State = (Get-ScheduledTask -TaskName 'Fail2ban-Service').State
            if( $State -ne 'Running') {
                Add-F2BLog -Type Error -Category '5' -Message "Unable to start Scheduled Task 'Fail2ban-Service', please check server log"
            }
        } else {
            if($State -eq 'Running') {
                Add-F2BLog -Type Information -Category '5' -Message "Scheduled Task 'Fail2ban-Service' already Running"
            } elseif ($State -eq 'Disabled') {
                Add-F2BLog -Type Warning -Category '5' -Message "Scheduled Task 'Fail2ban-Service' is Disabled"
            }
        }
    } else {
        Add-F2BLog -Type Error -Category '5' -Message "Unable to find Scheduled Task 'Fail2ban-Service'"
    }
}