# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + SETUP
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++
# + Install Fail2Ban
function Install-F2B(){
    # Create Regedit Key
    New-Item -Path HKLM:\SOFTWARE\ -Name "Fail2Ban"
    New-Item -Path HKLM:\SOFTWARE\Fail2Ban\ -Name "List"
    New-Item -Path HKLM:\SOFTWARE\Fail2Ban\List -Name "Black"
    New-Item -Path HKLM:\SOFTWARE\Fail2Ban\List -Name "White"
    New-Item -Path HKLM:\SOFTWARE\Fail2Ban\ -Name "Config"

    # Create Property
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "IP_BanTime" -Value "7200" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "IP_MaxRetry" -Value "10" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "CheckTime" -Value "30" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "FileLog_Enabled" -Value "True" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "FileLog_Format" -Value "csv" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "FileLog_Life" -Value "30" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "FileLog_Folder" -Value "$($env:PROGRAMFILES)\Fail2Ban\logs" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "EventLog_Enabled" -Value "True" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "EventLog_Id" -Value "4242" -PropertyType "String"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config\" -Name "EventLog_Name" -Value "Application" -PropertyType "String"

    #
    New-EventLog –LogName Application –Source "Fail2Ban"
    
    # Add Whitlist
    Add-F2BRegistryIP -IP '127.0.0.1' -Type White -Unlimited $true

    # Create Folders
    New-Item -ItemType directory -Path "$($env:PROGRAMFILES)\Fail2Ban"
    New-Item -ItemType directory -Path "$($env:PROGRAMFILES)\Fail2Ban\logs"
}

# ++++++++++++++++++++++++++
# + Remove Fail2Ban
function Remove-F2B(){
    # Remove Folder
    Remove-Item -Path "$($env:PROGRAMFILES)\Fail2Ban" -Recurse -Force

    # Remove Regedit Key
    Remove-Item -Path "HKLM:\SOFTWARE\Fail2Ban\" -Recurse -Force
}

# ++++++++++++++++++++++++++
# + Update Fail2Ban
function Update-F2B(){
}

# ++++++++++++++++++++++++++
# + Test Firewall Status
function Test-F2BFirewallStatus(){
    $Interface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Get-NetConnectionProfile
    if($Interface -ne $null) {
        if((Get-NetFirewallProfile  -Name $Interface.NetworkCategory).Enabled -eq $true){
            return $true
        } else {
            return $false
        }
    } else {
        return $false
    }
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + REGISTRY
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++
# + Test Registry IP
Function Test-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type
    )
    $Data = (Get-Item HKLM:\SOFTWARE\Fail2Ban\List\$Type\).Property
    if($Data -ne $null) {
        if($Data.Contains($IP)) {
            return $true
        } else {
            return $false
        }
    } else {
        return $false
    }
}

# ++++++++++++++++++++++++++
# + Add Registry IP
Function Add-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type,

        [Parameter(Mandatory=$false)]
        [ValidateSet($true,$false)]
        [bool]$Unlimited=$false
    )

    # If not Exist
    if((Test-F2BRegistryIP -IP $IP -Type $Type) -eq $false) {
        # Set Duration
        if($Unlimited -eq $true) {
            $Value = 'Unlimited'
        } else {
            $Value = ([String](Get-Date))
        }

        # Add IP
        Try {
            New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $IP -Value $Value -PropertyType "String"
            return $true
        } Catch {
            Write-Warning "Unable to add property to registry : $_"
            return $false
        }
    } else {
        Write-Warning "The property already exists"
        return $false
    }
}

# ++++++++++++++++++++++++++
# + Remove Registry IP
Function Remove-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type
    )

    if((Test-F2BRegistryIP -IP $IP -Type $Type) -eq $true) {
        Try {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $IP
            return $true
        } Catch {
            Write-Warning "Unable to remove property to registry : $_"
            return $false
        }
    } else {
        Write-Warning "The property is not exists"
        return $false
    }
}

# ++++++++++++++++++++++++++
# + Get Registry IP
Function Get-F2BRegistryIP(){
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Black','White')]
        [String]$Type
    )
    $Items = (Get-Item "HKLM:\SOFTWARE\Fail2Ban\List\$Type").Property
    $ReturnItems = @()
    foreach($Item in $Items) {
        $ReturnItem = [PSCustomObject] @{
            IP  = $Item
            Date = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $Item)
        }
        $ReturnItems += $ReturnItem
    }
    return $ReturnItems
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + FIREWALL
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++
# + Test Firewall Rule
function Test-F2BFirewallRule(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP
    )
    $Test = Get-NetFirewallRule -DisplayName "Fail2Ban - Block $IP" -ErrorAction SilentlyContinue
    if($Test -ne $null) {
        return $true
    } else {
        return $false
    }
}

# ++++++++++++++++++++++++++
# + Add Firewall Rule
function Add-F2BFirewallRule(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP
    )

    if((Test-F2BFirewallRule -IP $IP) -eq $false) {
        Try {
            $Params = @{
                DisplayName   = "Fail2Ban - Block $IP"
                Direction     = "Inbound"
                RemoteAddress = $IP
                Profile       = "Any"
                Action        = "Block"
            }
            New-NetFirewallRule @PArams

            return $true
        } Catch {
            return $false
        }
    } else {
        return $false
    }
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + System
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++
# + Get Config
function Get-F2BConfig(){
    $Items = (Get-Item "HKLM:\SOFTWARE\Fail2Ban\Config").Property
    $hashtable = @{}
    foreach( $Item in $Items ){
        $hashtable[$Item] = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\Config" -Name $Item)
    }
    return $hashtable
}

# ++++++++++++++++++++++++++
# + Set Config
function Set-F2BConfig(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [String]$Value
    )
    if(((Get-F2BConfig).($Name)) -ne $null) {
        Try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Config" -Name $Name -Value $Value
        } Catch {
            write-error "unable to set Config value"
        }
    } else {
        Write-Host "Config Not found"
    }
}

# ++++++++++++++++++++++++++
# + Get Module
function Get-F2BModule(){
    $Items = (Get-Item "HKLM:\SOFTWARE\Fail2Ban\Module").Property
    $ReturnItems = @()
    foreach($Item in $Items) {
        $ReturnItem = [PSCustomObject] @{
            Name  = $Item
            Value = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\Module" -Name $Item)
        }
        $ReturnItems += $ReturnItem
    }
    return $ReturnItems
}

# ++++++++++++++++++++++++++
# + Set Module
function Set-F2BModule(){
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [String]$Value
    )

    if(((Get-F2BModule).Name).Contains($Name) -eq $true) {
        Try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\Module" -Name $Name -Value $Value
        } Catch {
            write-error "unable to set module value"
        }
    } else {
        Write-Host "Module Not found"
    }
}

# ++++++++++++++++++++++++++
# + Get Event Log
function Get-F2BEventLog(){

    $Config = Get-F2BConfig
    $CheckTime = ($Config | Where-Object { $_.Name -eq 'CheckTime'}).value

    $AfterDate = (Get-Date).AddSeconds(-$CheckTime)
    $EventLogs = Get-EventLog -log Security -After $AfterDate -InstanceId 4625


    $Obj = @()
    foreach($EventLog in $EventLogs) {
        
        $Return = [PSCustomObject]@{
            Index    = $EventLog.Index
            Time     = $EventLog.TimeWritten
            Type     = $EventLog.EntryType
            Username = Get-Match -Patern "account name:\s+\w+" -Data $EventLog.message
            IP       = Get-Match -Patern "Source Network Address:\s+\d{1,3}(\.\d{1,3}){3}" -Data $EventLog.message
        }
    
        $Obj += $Return
    }
    
    Return $Obj
}

# ++++++++++++++++++++++++++
# + Add Event Log
function Add-F2BEventLog(){
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Information','Error','Warning')]
        [String]$Type,
        [Parameter(Mandatory=$true)]
        [String]$Message,
        [Parameter(Mandatory=$false)]
        [String]$Service='System',
        [Parameter(Mandatory=$true)]
        [Object]$Config
    )
    
    if($Config.FileLog_Enabled -eq "True") {
        
        # Add Message to Log File
        if($Config.FileLog_Format -eq 'csv'){
            $OutputObject = [PSCustomObject] @{
                Date    = Get-Date -Format "MM/dd/yyyy hh:mm:ss.fff tt"
                Type    = $Type
                Service = $Service
                Message = $Message
            }
            $LogFile = Join-Path -Path $Config.FileLog_Folder -ChildPath "Fail2Ban-Service.$($Config.FileLog_Format)"
            Export-Csv -Path $LogFile -InputObject $OutputObject -Append -NoTypeInformation -Encoding UTF8 -Delimiter ";"
        } else {
            $Output = '{0} [{1}] {2}' -f (Get-Date -Format s),$Type,$Message
            Add-Content -Path (Join-Path -Path $Config.FileLog_Folder -ChildPath "Fail2Ban-Service.log") -Value $Output
        }
    }

    # -------------
    # Windows Log
    if($Config.EventLog_Enabled -eq "True") {
        $Params = @{
            LogName   = $Config.EventLog_Name
            Source    = "Fail2Ban"
            EntryType = $Type
            EventId   = $Config.EventLog_Id
            Message   = $Message
        }
        Write-EventLog @Params
    }
}

# ++++++++++++++++++++++++++
# + Start Fail2ban
function Start-F2B(){}

# ++++++++++++++++++++++++++
# + Stop Fail2ban
function Stop-F2B(){}

# ++++++++++++++++++++++++++
# + Cleaning log file
function Initialize-F2BFileLogCleaning(){

    $Config = Get-F2BConfig

    if($Config.FileLog_Enabled -eq "True") {

    } else {

    }
}

# ++++++++++++++++++++++++++
# + File log rotate
function Initialize-F2BFileLogRotate(){

    $Config = Get-F2BConfig

    if($Config.FileLog_Enabled -eq "True") {
    # Stop service
    Stop-F2B


    # Stop service
    Start-F2B
    } else {

    }
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + Process
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++
# + Add Blocked IP
function Add-F2BBlockedIP () {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IP
    )

    # 
    
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + INTERNAL TOOL
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ++++++++++++++++++++++++++
# + Get Match Patern
function Get-Match(){
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