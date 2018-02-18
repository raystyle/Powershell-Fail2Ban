function Start-F2BSleep (){
    <#  
        .SYNOPSIS  
            Suspends the activity in a script or session for the specified period of time.

        .DESCRIPTION
            The New-Sleep cmdlet suspends the activity in a script or session for the specified period of time.
            You can use it for many tasks, such as waiting for an operation to complete or pausing before repeating an operation.

        .NOTES  
            Author      : Thomas ILLIET, contact@thomas-illiet.fr
            Date        : 2017-05-10
            Last Update : 2018-01-08
            Version     : 1.0.2

        .PARAMETER S
            Time to wait

        .PARAMETER Message
            Message you want to display

        .EXAMPLE  
            New-Sleep -S 60 -Message "wait and see"

        .EXAMPLE
            New-Sleep -S 60
    #>
    [cmdletbinding()]
    param
    (
        [parameter(Mandatory=$true)]
        [int]$S,
        [parameter(Mandatory=$false)]
        [string]$Message="Wait"
    )
    for ($i = 1; $i -lt $s; $i++) 
    {
        [int]$TimeLeft = $s - $i
        Write-Progress -Activity $message -PercentComplete (100 / $s * $i) -CurrentOperation "$TimeLeft seconds left" -Status "Please wait"
        Start-Sleep -s 1
    }
    Write-Progress -Completed $true -Status "Please wait"
}