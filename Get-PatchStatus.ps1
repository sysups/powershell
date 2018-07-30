    <#
    .SYNOPSIS
    Finds missing patches on devices.
    .DESCRIPTION
    A Function that calls itself.
    Finds missing patches on devices using a servers textfile for device input
    and a kb textfile to find missing KB numbers.
    #>

# Creating variables based on textfiles
$servers = Get-Content "servers.txt"
$kb = Get-Content "patches.txt"

# The function. Loops through all the servers from servers.txt and checks
# for the presence of the patches that are supplied in patches.txt
# Outputs the status of each server & patch to a patches_missing.txt
function Get-Patch
{
    $count = 0
        DO
        {
        $servers | ForEach-Object { if (!(Get-HotFix -Id $kb[$count] -ComputerName $_ -ErrorAction SilentlyContinue))
            {
            Write-Output $kb[$count]
            Write-Output $Error[0].Exception
            Add-Content -Path "patches_missing.txt" -Value (($kb[$count])+" "+($Error[0].Exception | Out-String))
            }
            }
            $count++
        } While ($count -lt $kb.count)
}

# The execution of the function.
Get-Patch
