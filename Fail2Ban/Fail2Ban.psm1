# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# + SETUP
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    # ++++++++++++++++++++++++++
    # + Install Fail2Ban
    function Install-F2B(){

        # Test Elevated User
        $AdminUser = Test-F2BAdmin
        if($AdminUser -eq $false) {
            Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
            break
        }

        # Get install configuration
        write-debug "# Get install configuration"
        Try {
            $ConfigFile = Get-Content (Join-Path -Path $PSScriptRoot -ChildPath "Config/Install.json") -ErrorAction Stop
            $Config =  $ConfigFile | ConvertFrom-Json
        } Catch {
            Write-Error "Unable to get configuration file : $_"
            break
        }

        # Create Registry Item
        Write-Debug "# Create Registry Items :"
        try {
            foreach($Item in $Config.Registry.Item){

                $RegistryPath = "$($Item.Path)/$($Item.Name)"
                Write-Debug "#`t- $RegistryPath"
            
                if((Test-Path $RegistryPath) -eq $false) {
                    New-Item -Path $Item.Path -Name $Item.Name -ErrorAction Stop | Out-Null
                }
            }
        } Catch {
            write-error "Unable to create registry Item ($RegistryPath) : $_"
            break
        }

        # Create Registry Property
        Write-Debug "# Create Registry Propertys :"
        Try {
            foreach($Item in $Config.Registry.Property){

                $RegistryPath = "$($Item.Path)/$($Item.Name)"
                $ItemCollection = (Get-Item $Item.Path).Property
                Write-Debug "#`t- $RegistryPath"

                if($ItemCollection.Contains($Item.Name) -eq $false) {
                    New-ItemProperty -Path $Item.Path -Name $Item.Name -Value $Item.Value -PropertyType $Item.Type -ErrorAction Stop | Out-Null
                }
            }
        } Catch {
            write-error "Unable to create Property Item ($RegistryPath) : $_"
            break
        }

        # Create Folders
        Write-Debug "# Create Folders :"
        Try {
            foreach($Item in $Config.Registry.folders){

                Write-Debug "#`t- $Item"

                if((Test-Path $Item) -eq $false) {
                    New-Item -ItemType directory -Path $Item -ErrorAction Stop | Out-null
                }
            }
        } Catch {
            write-error "Unable to create Folder ($Item) : $_"
            exit
        }

        # Create EventLog Source
        Write-Debug "# Create EventLog Source"
        if((Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\Fail2Ban") -eq $false) {
            Try {
                New-EventLog -LogName Application -Source "Fail2Ban" -ErrorAction Stop
            } Catch {
                Write-Error "Unable to create source into EventLog : $_"
                break
            }
        }

        # Create Scheduled Task
        Write-Debug "# Create Scheduled Task"
        if((Get-ScheduledTask -TaskName Fail2ban -ErrorAction SilentlyContinue) -eq $null) {
            Try {
                $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Retart-F2B}"'
                $trigger =  New-ScheduledTaskTrigger -Daily -At 0am
                Register-ScheduledTask -Action $action -Trigger $trigger -User "System" -TaskName "Fail2ban" -Description "Fail2Ban is an intrusion prevention Powershell framework that protects computer servers from brute-force attacks"  -ErrorAction Stop | Out-Null
            } Catch {
                Write-Error "Unable to create Scheduled Task : $_"
                break
            }
        }
    }

    # ++++++++++++++++++++++++++
    # + Remove Fail2Ban
    function Remove-F2B(){
        
        $Choice = Read-Host 'Do you really want to delete all data [yes/NO] '

        if($Choice -eq "yes") {

            # Remove Folder
            Write-Debug "# Remove Folder"
            Try {
                Remove-Item -Path "$($env:PROGRAMFILES)\Fail2Ban" -Recurse -Force -ErrorAction Stop
            } Catch {
                Write-Error "Unable to remove properly this folder : $_"
            }

            # Remove Registry Key
            Write-Debug "# Remove Registry Key"
            Try {
                Remove-Item -Path "HKLM:\SOFTWARE\Fail2Ban\" -Recurse -Force -ErrorAction Stop
            } Catch {
                Write-Error "Unable to remove properly this registry Key : $_"
            }

            # Remove scheduled Task
            Write-Debug "# Remove scheduled Task"
            Try {
                Unregister-ScheduledTask -TaskName "Fail2Ban" -Confirm:$false
            } Catch {
                write-error "Unable to Remove scheduled Task"
            }

         } else {
            Write-Output "Operation canceled"
         }
    }

    # ++++++++++++++++++++++++++
    # + Update Fail2Ban
    function Update-F2B(){
    
        # Update Module
        Write-Debug "# Module update from Powershell Gallery"
        Try {
            Update-Module -Name "Fail2Ban" -Force
        } Catch {
            Write-Error "Unable to update Module : $_"
        }

        # Execute install
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

        $hashtable = @{}
        foreach( $Item in $Items ){
            $hashtable[$Item] = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\List\$Type" -Name $Item)
        }
        return $hashtable
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

    # ++++++++++++++++++++++++++
    # + Remove Firewall Rule
    function Remove-F2BFirewallRule(){
        Param(
            [Parameter(Mandatory=$true)]
            [String]$IP
        )

        if((Test-F2BFirewallRule -IP $IP) -eq $true) {
            Try {
                Remove-NetFirewallRule -DisplayName "Fail2Ban - Block $IP"
                return $true
            } Catch {
                return $false
            }
        } else {
            return $false
        }
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
    # + Restart Fail2ban
    function Restart-F2B(){}

    # ++++++++++++++++++++++++++
    # + Test Status Fail2ban
    function Test-F2BStatus(){}

    # ++++++++++++++++++++++++++
    # + Cleaning log file
    function Initialize-F2BFileLogCleaning(){}

    # ++++++++++++++++++++++++++
    # + File log rotate
    function Initialize-F2BFileLogRotate(){}

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
        if((Get-F2BRegistryIP -Type White).contains($IP) -eq $false) {
            if((Add-F2BRegistryIP -IP $IP -Type Black) -eq $true) {
                if((Add-F2BFirewallRule -IP $IP) -eq $true) {
                    return $true
                } else {
                    return $false
                }
            } else {
                return $false
            }
        } else {
            return $false
        }        
    }

    function Remove-F2BBlockedIP () {
        Param(
            [Parameter(Mandatory=$true)]
            [String]$IP
        )
        if((Remove-F2BRegistryIP -IP $IP -Type Black) -eq $true) {
            if((Remove-F2BFirewallRule -IP $IP) -eq $true) {
                return $true
            } else {
                return $false
            }
        } else {
            return $false
        }
     
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

    # ++++++++++++++++++++++++++
    # + Test Admon Elevation
    function Test-F2BAdmin(){
        $CurrentWindowsIdentity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        If ($CurrentWindowsIdentity.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") -eq $true){
            return $true
        } else {
            return $false
        }
    }