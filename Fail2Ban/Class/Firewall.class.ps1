class F2BFirewall {
    #+++++++++++++++++++++++
    # Properties
    [IpAddress] $IP

    #+++++++++++++++++++++++
    # Constructor
    F2BFirewall ([IpAddress] $IP){
        $this.IP = $IP
    }

    #+++++++++++++++++++++++
    # Method : Remove 
    [Boolean] Remove() {
        if($this.Get() -ne $false) {
            Try {
                Remove-NetFirewallRule -DisplayName "Fail2Ban - Block $($this.IP)" -ErrorAction Stop
                return $true
            } Catch {
                return $_
            }
        } else {
            return $false
        }
    }

    #+++++++++++++++++++++++
    # Method + Add
    [Object] Add() {
        if($this.Get() -eq $false) {
            Try {
                $Params = @{
                    DisplayName   = "Fail2Ban - Block $($this.IP)"
                    Direction     = "Inbound"
                    RemoteAddress = $this.IP
                    Profile       = "Any"
                    Action        = "Block"
                }
                $Obj = New-NetFirewallRule @Params -ErrorAction Stop 
                return $Obj
            } Catch {
                return $_
            }
        } else {
            return $false
        }
    }

    #+++++++++++++++++++++++
    # Method Get
    [Object] Get() {
        $Obj = Get-NetFirewallRule -DisplayName "Fail2Ban - Block $($this.IP)" -ErrorAction SilentlyContinue
        if($Obj -ne $null) {
            return $Obj
        } else {
            return $false
        }
    }
}