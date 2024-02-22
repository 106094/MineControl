#(Get-Content -Path "interface.html" -Raw) | Select-String -Pattern "load0" | ForEach-Object { Write-Host "位置: $($_.Matches.Index)" }


#(Get-Content -Path "interface.html" -Raw) | Select-String -Pattern "load0" | ForEach-Object { $_.Remove((Get-Content -Path "interface.html" -Raw)[$_.Matches.Index+7] , 20)  }

#(Get-Content -Path "interface.html" -Raw) | Select-String -Pattern "load0" | ForEach-Object { Write-Host (Get-Content -Path "interface.html" -Raw)[$_.Matches.Index+7+20] }




#$content = Get-Content -Path "interface.html" -Raw
#$matches = Select-String -Pattern "load0" -InputObject $content
#foreach ($match in $matches) {
#    $index = $match.Matches.Index
#    $content = $content.Remove($index + 7, 21)
#}
#$content | Set-Content -Path "interface.html"


#(Get-Content -Path "interface.html" -Raw) -replace "(?s)(load0.{21})", "" | Set-Content -Path "interface.html"

param(
    [string]$Eleid,
    [string]$Action
)

    if((Get-Content -Path "interface.html" -Raw).IndexOf("<p id='load$Eleid'>Fail. Please reconnect.</p>") -eq -1){
        (Get-Content -Path "interface.html" -Raw) -replace "('load$Eleid').{22}", '$1' -replace "('load$Eleid'>).{10}", '$1Fail. Please reconnect.' | Set-Content -Path "interface.html"
    }else{
        if($Action){
            (Get-Content -Path "interface.html" -Raw) -replace "('load$Eleid'>).{23}", '$1' -replace "('load$Eleid'>).{0}", '$1Loading...' -replace "('load$Eleid').{0}", '$1 style="display:none;"' | Set-Content -Path "interface.html"
        }
    }

    

#$test -replace "('load0'>).{10}", '$1Fail. Please reconnect.'