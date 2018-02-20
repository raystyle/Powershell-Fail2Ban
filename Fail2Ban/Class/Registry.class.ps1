class F2BRegistry {
    #+++++++++++++++++++++++
    # Properties
    [ValidateSet('Black','White')]
    [String] $Type
    [IpAddress] $IP
    [Boolean] $Unlimited

    #+++++++++++++++++++++++
    # Constructor
    F2BRegistry ([String] $Type, [IpAddress] $IP){
        $this.Type = $Type
        $this.IP = $IP
    }

    #+++++++++++++++++++++++
    # Constructor
    F2BRegistry ([String] $Type, [IpAddress] $IP, [Boolean] $Unlimited){
        $this.Type = $Type
        $this.IP = $IP
        $this.Unlimited = $Unlimited
    }


    #+++++++++++++++++++++++
    # Method - Remove 
    [Boolean] Remove() {
        if(($this.GetItems() -contains '127.0.0.9') -eq $true){
            Try {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\List\$($this.Type)" -Name $this.IP -ErrorAction Stop
                return $true
            } Catch {
                Throw [System.NotImplementedException]::New("Unable to Remove Item : $_")
            }
        } else {
            return $false
        }
    }

    #+++++++++++++++++++++++
    # Method - Add
    [Object] Add() {
        if(($this.GetItems() -notcontains $this.IP) -eq $true){
            Try {
                # Set Duration
                if($this.Unlimited -eq $true) { $Value = 'Unlimited' }
                else { $Value = ([String](Get-Date)) }
                # Add Item
                $obj = New-ItemProperty -Path "HKLM:\SOFTWARE\Fail2Ban\List\$($this.Type)" -Name $this.IP -Value $Value -PropertyType "String" -ErrorAction stop
                return $obj
            } Catch {
                Throw [System.NotImplementedException]::New("Unable to Add Item : $_")
            }
        } else {
            return $false
        }
    }

    #+++++++++++++++++++++++
    # Method - Get
    [Object] Get(){
        if(($this.GetItems() -contains $this.IP) -eq $true){
            $Value = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Fail2Ban\List\$($this.Type)" -Name $this.IP
            if($Value -ne $null) {
                return [PSCustomObject] @{
                    IP = $this.IP
                    Value = $Value
                }
            } else {
                return $false
            }
        } else {
            return $false
        }
    }

    #+++++++++++++++++++++++
    # Method - GetItem
    Hidden [Array] GetItems() {
        $AllObj = $Items = (Get-Item "HKLM:\SOFTWARE\Fail2Ban\List\$($this.Type)").Property
        return $AllObj
    }
}