$stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

$script:listWLAN = New-Object System.Collections.Generic.HashSet[long]
$script:listARP = New-Object System.Collections.Generic.HashSet[long]

# Function declaration

function Read-WLAN {
    $file = Get-Content -Path "B:\MacAddressSuspectMatch\src\macaddresssuspectmatch\wlan.txt"
    $i = 0

    foreach ($line in $file) {
        if ($line -match "[a-z0-9][a-z0-9]:[a-z0-9][a-z0-9]:[a-z0-9][a-z0-9]:[a-z0-9][a-z0-9]:[a-z0-9][a-z0-9]:[a-z0-9][a-z0-9]") {
            $read = $line.split(" ")[0]
            $null = $script:listWLAN.Add([System.Convert]::ToInt64($read.replace(":", ""), 16))
        }

        $i++
    }

}

function Read-ARP {
    $file = Get-Content -Path "B:\MacAddressSuspectMatch\src\macaddresssuspectmatch\arp.txt"
    $i = 0
    foreach ($line in $file) {
        if($line -match "[a-z0-9][a-z0-9][a-z0-9][a-z0-9][.][a-z0-9][a-z0-9][a-z0-9][a-z0-9][.][a-z0-9][a-z0-9][a-z0-9][a-z0-9]"){
            $read = $line -split "\s{1,}"
            if ($read.Length -ge 3) {
                $read = $read[3]
            }
            else {
                continue
            }
            $null = $script:listARP.Add([System.Convert]::ToInt64($read.replace(".", ""), 16))
        }

        $i++
    }
    
}
$D = $stopWatch.Elapsed.TotalSeconds
Read-WLAN

Write-Host "`nReading WLAN took $($stopWatch.Elapsed.TotalSeconds - $D) seconds to complete."

$D = $stopWatch.Elapsed.TotalSeconds

Read-ARP

Write-Host "`nReading ARP took $($stopWatch.Elapsed.TotalSeconds - $D) seconds to complete."

$D = $stopWatch.Elapsed.TotalSeconds

$matches = foreach ($WLAN in $listWLAN) {
    for ($i = 1; $i -le 8; $i++) {
        if ($listARP.Contains(($WLAN - $i))) {
            [PSCustomObject]@{
                WLAN = "{0:X0}" -f $WLAN
                ARP  = "{0:X0}" -f ($WLAN - $i)
            }
        }
    }
}

Write-Host "`nFinding matches took $($stopWatch.Elapsed.TotalSeconds - $D) seconds to complete."

$stopWatch.Stop()

Write-Host "`nAdrian total script took $($stopWatch.Elapsed.TotalSeconds) seconds to complete."
Write-Host "Matches:`n"
$matches