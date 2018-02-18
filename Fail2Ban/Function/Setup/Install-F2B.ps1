<#
    .NOTES  
        File Name   : Install-F2B
        Author      : Thomas ILLIET, contact@thomas-illiet.fr
        Date        : 2018-02-15
        Last Update : 2018-02-15
        Version     : 1.0.1
#>

function Install-F2B(){

    Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "Fail2Ban Install"
    Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow

    # Get install configuration
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Get install configuration"
    Try {
        $ConfigFile = Get-Content (Join-Path -Path $F2BModuleRoot -ChildPath "Config/Install.json") -ErrorAction Stop
        $Config =  $ConfigFile | ConvertFrom-Json
    } Catch {
        Write-Error "Unable to get configuration file : $_"
        break
    }

    # Create Registry Item
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Create Registry Items :"
    try {
        foreach($Item in $Config.Registry.Item){

            $RegistryPath = "$($Item.Path)/$($Item.Name)"
            Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "`t- $RegistryPath"
        
            if((Test-Path $RegistryPath) -eq $false) {
                New-Item -Path $Item.Path -Name $Item.Name -ErrorAction Stop | Out-Null
            }
        }
    } Catch {
        write-error "Unable to create registry Item ($RegistryPath) : $_"
        break
    }

    # Create Registry Property
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Create Registry Propertys"
    Try {
        foreach($Item in $Config.Registry.Property){

            $RegistryPath = "$($Item.Path)/$($Item.Name)"
            $ItemCollection = (Get-Item $Item.Path).Property
            Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "`t- $RegistryPath"

            if($ItemCollection.Contains($Item.Name) -eq $false) {
                New-ItemProperty -Path $Item.Path -Name $Item.Name -Value $Item.Value -PropertyType $Item.Type -ErrorAction Stop | Out-Null
            }
        }
    } Catch {
        write-error "Unable to create Property Item ($RegistryPath) : $_"
        break
    }

    # Create Folders
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Create Folders :"
    Try {
        foreach($Item in $Config.Registry.folders){

            Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "`t- $Item"
            if((Test-Path $Item) -eq $false) {
                New-Item -ItemType directory -Path $Item -ErrorAction Stop | Out-null
            }
        }
    } Catch {
        write-error "Unable to create Folder ($Item) : $_"
        exit
    }

    # Create EventLog Source
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Create EventLog Source"
    if((Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\Fail2Ban") -eq $false) {
        Try {
            New-EventLog -LogName Application -Source "Fail2Ban" -ErrorAction Stop
        } Catch {
            Write-Error "Unable to create source into EventLog : $_"
            break
        }
    }

    # Create Scheduled Task
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "- Create Scheduled Task :"
    Try {
        # Service
        Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "`t- Fail2ban-Service"
        if((Get-ScheduledTask -TaskName "Fail2Ban-Manager" -ErrorAction SilentlyContinue) -eq $null) {
            $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Import-Module Fail2ban; Initialize-F2BService}"'
            $trigger =  New-ScheduledTaskTrigger -AtStartup
            Register-ScheduledTask -Action $action -Trigger $trigger -User "System" -TaskName "Fail2Ban-Service" -Description "Fail2Ban is an intrusion prevention Powershell framework that protects computer servers from brute-force attacks"  -ErrorAction Stop | Out-Null
        }

        # Manager
        Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "`t- Fail2ban-Manager"
        if((Get-ScheduledTask -TaskName "Fail2Ban-Manager" -ErrorAction SilentlyContinue) -eq $null) {
            $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Retart-F2B}"'
            $trigger =  New-ScheduledTaskTrigger -Daily -At 0am
            Register-ScheduledTask -Action $action -Trigger $trigger -User "System" -TaskName "Fail2Ban-Manager" -Description "Fail2Ban is an intrusion prevention Powershell framework that protects computer servers from brute-force attacks"  -ErrorAction Stop | Out-Null
        }
    } Catch {
        Write-Error "Unable to create Scheduled Task : $_"
        break
    }

    Write-Host "# ++++++++++++++++++++++++++++++++++++++ " -ForegroundColor Yellow
}