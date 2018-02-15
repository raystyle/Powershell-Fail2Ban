<#
    .NOTES  
        File Name   : Install-F2B
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.1
#>

function Install-F2B(){

    # Get install configuration
    write-Output "# Get install configuration"
    Try {
        $ConfigFile = Get-Content (Join-Path -Path $F2BModuleRoot -ChildPath "Config/Install.json") -ErrorAction Stop
        $Config =  $ConfigFile | ConvertFrom-Json
    } Catch {
        Write-Error "Unable to get configuration file : $_"
        break
    }

    # Create Registry Item
    Write-Output "# Create Registry Items :"
    try {
        foreach($Item in $Config.Registry.Item){

            $RegistryPath = "$($Item.Path)/$($Item.Name)"
            Write-Output "#`t- $RegistryPath"
        
            if((Test-Path $RegistryPath) -eq $false) {
                New-Item -Path $Item.Path -Name $Item.Name -ErrorAction Stop | Out-Null
            }
        }
    } Catch {
        write-error "Unable to create registry Item ($RegistryPath) : $_"
        break
    }

    # Create Registry Property
    Write-Output "# Create Registry Propertys :"
    Try {
        foreach($Item in $Config.Registry.Property){

            $RegistryPath = "$($Item.Path)/$($Item.Name)"
            $ItemCollection = (Get-Item $Item.Path).Property
            Write-Output "#`t- $RegistryPath"

            if($ItemCollection.Contains($Item.Name) -eq $false) {
                New-ItemProperty -Path $Item.Path -Name $Item.Name -Value $Item.Value -PropertyType $Item.Type -ErrorAction Stop | Out-Null
            }
        }
    } Catch {
        write-error "Unable to create Property Item ($RegistryPath) : $_"
        break
    }

    # Create Folders
    Write-Output "# Create Folders :"
    Try {
        foreach($Item in $Config.Registry.folders){

            Write-Output "#`t- $Item"

            if((Test-Path $Item) -eq $false) {
                New-Item -ItemType directory -Path $Item -ErrorAction Stop | Out-null
            }
        }
    } Catch {
        write-error "Unable to create Folder ($Item) : $_"
        exit
    }

    # Create EventLog Source
    Write-Output "# Create EventLog Source"
    if((Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\Fail2Ban") -eq $false) {
        Try {
            New-EventLog -LogName Application -Source "Fail2Ban" -ErrorAction Stop
        } Catch {
            Write-Error "Unable to create source into EventLog : $_"
            break
        }
    }

    # Create Scheduled Task
    Write-Output "# Create Scheduled Task"
    Try {
        # Service
        if((Get-ScheduledTask -TaskName "Fail2ban-Manager" -ErrorAction SilentlyContinue) -eq $null) {
            $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Import-Module Fail2ban; Initialize-F2BService}"'
            $trigger =  New-ScheduledTaskTrigger -AtStartup
            Register-ScheduledTask -Action $action -Trigger $trigger -User "System" -TaskName "Fail2ban-Service" -Description "Fail2Ban is an intrusion prevention Powershell framework that protects computer servers from brute-force attacks"  -ErrorAction Stop | Out-Null
        }

        # Manager
        if((Get-ScheduledTask -TaskName "Fail2ban-Manager" -ErrorAction SilentlyContinue) -eq $null) {
            $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Retart-F2B}"'
            $trigger =  New-ScheduledTaskTrigger -Daily -At 0am
            Register-ScheduledTask -Action $action -Trigger $trigger -User "System" -TaskName "Fail2ban-Manager" -Description "Fail2Ban is an intrusion prevention Powershell framework that protects computer servers from brute-force attacks"  -ErrorAction Stop | Out-Null
        }
    } Catch {
        Write-Error "Unable to create Scheduled Task : $_"
        break
    }
    
    # Start Fail2ban 
    Write-Output "# Start Fail2ban"
    if(Start-F2B -ne $true) {
        write-error "Unable to start Fail2ban"
        break
    }
}