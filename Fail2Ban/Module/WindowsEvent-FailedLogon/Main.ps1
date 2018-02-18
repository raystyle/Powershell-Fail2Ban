function Use-WEFL () {
    Param(
        $ConfigModule,
        $ConfigSystem
    )                  
       
    # ++++++++++++++++++++++++
    # Internal Function
    function Get-F2BMatch(){
        Param(
            [Parameter(Mandatory=$true)]
            [String]$Pattern,
            [Parameter(Mandatory=$true)]
            [String]$Data
        )
    
        $Content = $Data | Select-String -pattern $Pattern -AllMatches | select -ExpandProperty matches | select -ExpandProperty value
        if($content.Count -eq 2) {
            $Match = $content[1]
        } else {
            $Match =  $content
        }
        $Match = (($Match -split ":")[1]) -replace "\s+",""
    
        return $Match
    }

    # ++++++++++++++++++++++++
    # Get Windows Event
    $AfterDate = (Get-Date).AddSeconds("-$($ConfigModule.Wefl_MaxAttemptTime)")
    $events = Get-WinEvent -FilterHashtable @{ProviderName= "Microsoft-Windows-Security-Auditing"; LogName = "security"; Id = "4625"; StartTime = [datetime]$AfterDate}
    
    # ++++++++++++++++++++++++
    # Format Events
    $ReturnObj =@()
    Foreach($i in $events) {
        # LogonType
        $LogonID = Get-F2BMatch -Pattern "Logon Type:\s+\w+" -Data $i.message
        switch($LogonID) {
            2 { $logontype = "Interactive" }
            3 { $logontype = "Network" }
            7 { $logontype = "Computer Unlocked"}
        }

        $Obj = [PSCustomObject] @{
            Id = $i.RecordId
            Username = Get-F2BMatch -Pattern "account name:\s+\w+" -Data $i.message
            Date = $i.TimeCreated
            IP = Get-F2BMatch -Pattern "Source Network Address:\s+\d{1,3}(\.\d{1,3}){3}" -Data $i.message
            LogonType = $logontype
        }
        $ReturnObj += $Obj
    }

    # ++++++++++++++++++++++++
    # Blocking address
    $IpGroup = $ReturnObj | group IP
    Foreach($Group in $IpGroup) {
        if($Group.Count -ge $ConfigModule.Wefl_MaxAttemptCount){
            if((Test-F2BRegistryIP -IP $Group.Name -Type Black) -eq $false) {
                Add-F2BAddress -IP $Group.Name -Type Black | out-null
                Write-F2BConsole -Type Information -Message "+ Blocking address $($Group.Name)"
            }
        }
    }

    # ++++++++++++++++++++++++
    # Unblocking address
    $BlockedAddress = Get-F2BRegistryIP -Type Black
    foreach ($item in $BlockedAddress.GetEnumerator()) {
        if($item.Value -ne 'Unlimited') {
            if((([DateTime]$item.Value).AddSeconds($ConfigModule.Wefl_BanTime)) -le (get-date)) {
                Remove-F2BAddress -IP $item.Key -Type Black | out-null
                Write-F2BConsole -Type Information -Message "+ Unblocking address $($item.Key)"
            }
        }
    }

    # ++++++++++++++++++++++++
    # Stats
    #if($ConfigModule.Wefl_Stats -eq "1"){
    # 
    #}    
}