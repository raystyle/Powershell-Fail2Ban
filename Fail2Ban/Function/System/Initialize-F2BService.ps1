function Initialize-F2BService(){
    <#
    .SYNOPSIS
        .
    .EXAMPLE
        C:\PS> Initialize-F2BService
    .NOTES
        Author      : Thomas ILLIET
        Date        : 2018-02-15
        Last Update : 2018-02-15
    #>

    Try {
        Write-Host "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor yellow
        Write-F2BConsole -Type Information -Message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"  
        Write-F2BConsole -Type Information -Message "+ Initialize Fail2Ban Service"
        Write-F2BConsole -Type Information -Message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        # ++++++++++++++++++++++++
        # Get Configuration
        Write-F2BConsole -Type Information -Message "Get Configuration"
        $ConfigSystem = Get-F2BConfig -ConfigFolder System
        $ConfigModule = Get-F2BConfig -ConfigFolder Module

        # ++++++++++++++++++++++++
        # Load Module
        Write-F2BConsole -Type Information -Message "Get Module :"
        $ModuleFile = Get-Content (Join-Path -Path $F2BModuleRoot -ChildPath "Config/Module.json") -ErrorAction Stop
        $Modules =  ($ModuleFile | ConvertFrom-Json ).Module

        foreach ($Module in $Modules) {
            if((($ConfigModule).("$($Module.Prefix)_Status")) -eq "1"){
                Write-F2BConsole -Type Information -Message "+ $($Module.Prefix) ($($Module.Name))"
                . (join-Path -Path $F2BModuleRoot -ChildPath "Module\$($Module.FilePath)")
            }
        }

        # ++++++++++++++++++++++++
        # Loop
        Write-F2BConsole -Type Information -Message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"  
        Write-F2BConsole -Type Information -Message "+ Run the loop every $($ConfigSystem.Service_Loop) seconds ..."
        Write-F2BConsole -Type Information -Message "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        while($true)
        {
            # Execute Module
            foreach ($Module in $Modules) {
                Write-F2BConsole -Type Information -Message "Execute Module - $($Module.Prefix) "
                & "Use-$($Module.Prefix)" -ConfigModule $ConfigModule -ConfigSystem $ConfigSystem
            }

            # Wait to next step
            Start-F2BSleep -S $ConfigSystem.Service_Loop -Message "Wait next Loop ..."
        }

    } Catch {
        Write-F2BConsole -Type Error -Message "An error has occurred : $_"
    } finally {
        Write-F2BConsole -Type Information -Message "Stop Fail2Ban Service"
        Write-Host "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor yellow
    }
}