  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

 write-host "check connect"

   Add-Type -AssemblyName System.Windows.Forms
   $ping = New-Object System.Net.NetworkInformation.Ping

 $test2= ($ping.Send("192.168.2.249", 1000)).Status
  $test6= ($ping.Send("192.168.60.16", 1000)).Status

  if( !($test2 -match "Success") -or !($test6 -match "Success")){
  [System.Windows.Forms.MessageBox]::Show($this,"需同時連線Allion大網和Local測網(Lab322 192.168.2網段)")
  exit
  }
  
  function Test-Admin {
param([switch]$Elevated)
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
 
$checkadmincre=test-path "\\192.168.20.20\sto\EO\2_AutoTool\ALL\103.Dell_AITest\MineControl\RemoteUI\" #admin cmd check credential

if(!$checkadmincre){
write-host "need setting 192.168.20.20 credentail"
}

if ((Test-Admin) -eq $false -or $checkadmincre -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process $PsHome\powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    
   if(!((cmdkey /list) -match "20.20")){
  
        $elevated=$true
        $targetpath="192.168.20.20"
        $usernm=read-host "the login of $targetpath (ex: Allionlab\<myname>) " 
        $passwd=read-host "the password of $targetpath　" -AsSecureString
        if($usernm -notmatch "allionlab"){$usernm="Allionlab\"+$usernm}
        $Newpass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwd))
          cmdkey /add:$targetpath /user:$usernm /pass:$Newpass
       
          Start-Process $PsHome\powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
   
             }

   
    }

    Start-Sleep -s 2
    $checkps=(get-process -name powershell).MainWindowTitle

    if($checkps -match "admin"){exit}
    else{
     cmdkey /delete:$targetpath
    [System.Windows.Forms.MessageBox]::Show($this,"credential setting error, program will exit, please try again")
    
    }
    
    exit
}

$checkadmin=get-process powershell|?{$_.mainwindowtitle -match "admin"}
if($checkadmin){
write-host "admin ok"
}

write-host "check 60"
if(!((cmdkey /list) -match "60.16")){
 $targetpath="192.168.60.16"
 $usernm=$Newpass="pctest"
 cmdkey /add:$targetpath /user:$usernm /pass:$Newpass
}

if(!((cmdkey /list) -match "2.249")){
 $targetpath="192.168.2.249"
 $usernm=$Newpass="pctest"
 cmdkey /add:$targetpath /user:$usernm /pass:$Newpass
}

if(!(Test-Path "C:\Program Files\RemoteTool")){
    New-Item -Path "C:\Program Files\RemoteTool" -ItemType Directory -Force|out-null
    gci -Path "\\192.168.20.20\sto\EO\2_AutoTool\ALL\103.Dell_AITest\MineControl\RemoteUI\*" -exclude "*.msi"|`
    Copy-Item -Destination "C:\Program Files\RemoteTool\" -Recurse -Force

    #create shrotcut to desktop
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("C:\Users\$env:USERNAME\Desktop\RemoteTool.lnk")

    $shortcut.TargetPath = "C:\Program Files\RemoteTool\start.bat"
    $shortcut.WorkingDirectory = "C:\Program Files\RemoteTool\"
    $shortcut.Description = "start"
    $shortcut.IconLocation = "C:\Program Files\RemoteTool\start.bat"
    #$shortcut.Arguments = "YourArgumentsHere"
    $shortcut.Save()
}

$scriptRoot="C:\Program Files\RemoteTool\"

Set-Location $scriptRoot

$rec_txt="\\192.168.60.16\srvprj\Inventec\Dell\Matagorda\07.Tool\_AutoTool_Monitor\start_records.txt"
#$rec_csv0="\\192.168.60.16\srvprj\Inventec\Dell\Matagorda\07.Tool\_AutoTool_Monitor\start_records0.csv"
#$rec_csv1="\\192.168.60.16\srvprj\Inventec\Dell\Matagorda\07.Tool\_AutoTool_Monitor\start_records1.csv"
$rec_csv0="$scriptRoot\start_records0.csv"
$rec_csv1="$scriptRoot\start_records1.csv"
$rec_csv="$scriptRoot\start_records.csv"

 $logs=$null
 
if((test-path $rec_txt)){

    $electronstatus = Get-Process -Name "electron" -ErrorAction SilentlyContinue
 
    if(!$electronstatus){
     $env:Path+=";"+"C:\Program Files\nodejs"
    #region check npm install and install npm/electron
        try{
            npm -v
        }catch{
        echo "Starting install npm ..."
            #msiexec /i "\\192.168.20.20\sto\EO\2_AutoTool\ALL\103.Dell_AITest\MineControl\RemoteUI\node-v18.18.2-x64.msi" /quiet
            Start-Process "\\192.168.20.20\sto\EO\2_AutoTool\ALL\103.Dell_AITest\MineControl\RemoteUI\node-v20.9.0-x64.msi"
            
            while(!($checknpm)){
             Start-Sleep -s 5
             $checknpm=1
               try{
                    npm -v
                }catch{
                $checknpm=0
                }  
            }

    
            echo "npm install completed"           

            

        }
 
    if(!(Test-Path "$scriptRoot\node_modules")){
        echo "Starting install electron ..."
             
            Start-Sleep -s 5

            npm install electron --save-dev

            echo "electron install completed"
    }

          



       }
       

    #region transfer txt to csv raw

    $inirecds=get-content $rec_txt |Select-Object -Skip 1|Where-Object{ (get-date ($_.split(" "))[0]) -gt (get-date).AddDays(-14)}
    $i=0
    foreach($inirecd in $inirecds){
        $i++
        $perc=[math]::Round($i/($inirecds.Count)*100,0)
        #Write-Progress -Activity "get 14 days data" -Status "$($perc)% Complete:" -PercentComplete $perc

    $newline=($inirecd.split("|"))

    $logs=$logs+@( 
       [pscustomobject]@{
       
           Tester=$newline[1]
           MachineName=$newline[2]
           iDracIP=$newline[3]
           IPv4IP=(($newline[4]).split(" "))[0]
           ini_Time=((get-date($newline[0]) -Format "yyyy/M/d")|Out-String).TrimEnd()
           log_folder="\\$($newline[2])\c\testing_AI\logs\"
           Last_TC=""
           Last_Step=""
           Last_Program=""
           Last_RunTime=""

           }
           )
    }
    #Write-Progress -Activity "get 14 days data" -Completed 
    $logs   | export-csv -path  $rec_csv0 -NoTypeInformation -Append

    #endregion

    #region sort within 1 month and uniqe machine name

    $sortdata=Import-Csv $rec_csv0|  Sort-Object MachineName,{get-date($_.ini_time)}

    $previousCategory = $null
    $filteredData = @()

    # Iterate through the sorted data
    foreach ($row in $sortdata) {
        if ($row.MachineName -ne $previousCategory) {
            # If the current row has a different category, add it to the filtered data
            $filteredData += $row
            $previousCategory = $row.MachineName
        } else {
            # If the current row has the same category as the previous one, update the filtered data
            $filteredData[-1] = $row
        }
    }

     $filteredData | export-csv -path  $rec_csv1 -NoTypeInformation 

    $sortdata=Import-Csv $rec_csv1 | Sort-Object IPv4IP,{get-date($_.ini_time)}
    $previousipv4= $null
    $filteredData2 = @()
     foreach($row in $sortdata){
         if ($row.IPv4IP -ne $previousipv4) {
            # If the current row has a different category, add it to the filtered data
            $filteredData2 += $row
            $previousipv4 = $row.IPv4IP
                } else {
            # If the current row has the same category as the previous one, update the filtered data
            $filteredData2[-1] = $row
        }
 
     }
 
 
    $filteredData2 | export-csv -path  $rec_csv1 -NoTypeInformation 
 

    #endregion
 
    #region ping and copy files

     $getcsvs = import-csv -path  $rec_csv1

     $copytoroot="\\192.168.60.16\srvprj\Inventec\Dell\Matagorda\07.Tool\_AutoTool_Monitor\logs\"
 
        #$jobs = @()
        #$connect_machines = $disconnect_machines = @()

        #$testConnectionScriptBlock = {

        #param($getcsv,$copytoroot)
   
         #}
    #---------------------------------------------------------

    $jobresult = @()
    $i=0
    foreach($getcsv in $getcsvs){
        #$job = Start-Job -ScriptBlock $testConnectionScriptBlock -ArgumentList $getcsv,$copytoroot
        #$jobs += $job
        #Get-Job|Out-Null
    
        $i++
        $perc=[math]::Round($i/($getcsvs.Count)*100,0)
        Write-Progress -Activity "IP scanning" -Status "$($perc)% Complete:" -PercentComplete $perc

        $ipend=$getcsv.IPv4IP
        $mnend=$getcsv.MachineName

        $ping = New-Object System.Net.NetworkInformation.Ping
        $checkconnect=$ping.Send($ipend, 1000)

        if($checkconnect.status -match "success"){

        #Write-Output "$mnend connect-pass"
        $jobresult += "$mnend connect-pass"

        $logpath="\\"+$mnend+"\c\testing_AI\logs\logs_timemap.csv"
        $copyto= $copytoroot+"$mnend"
    
        if(!(test-path $copyto)){
            new-item -ItemType directory $copyto|Out-Null
        }
        
       Copy-Item $logpath -Destination $copyto -Force -ErrorAction SilentlyContinue
   
        if(!$?){
            #Write-Output "$mnend copy-fail $logpath"
            $jobresult += "$mnend copy-fail $logpath"
        }
        else{
          #Write-Output "$mnend copy-pass $logpath"
          $jobresult += "$mnend copy-pass $logpath"
        }
   
       }
       else{
          #Write-Output "$mnend connect-fail"
          $jobresult += "$mnend connect-fail"
            }
            #---
    }

    Write-Progress -Activity "IP scanning" -Completed

        # 等待所有作业完成
        #$jobs | Wait-Job|Out-Null

        # 保存作业输出到文件

        #$jobresult = @()
        #$jobresult = $jobs | Receive-Job

        # 清理作业
        #$jobs | Remove-Job    
 
     #get connect lists

      $faillist = @()
      $passlist = @()
      $faillist2 = @()
      $passlist2 = @()

      for($i =0; $i -lt $jobresult.Length; $i++){
         if( $jobresult[$i] -match "connect-fail"){
             $faillist+= ($jobresult[$i].Split(" "))[0]
         }  
         if( $jobresult[$i]  -match "connect-pass"){
             $passlist+= ($jobresult[$i].Split(" "))[0]
         }  
              if( $jobresult[$i]  -match "copy-fail"){
             $faillist2+= ($jobresult[$i].Split(" "))[0]
         }  
         if( $jobresult[$i]  -match "copy-pass"){
             $passlist2+= ($jobresult[$i].Split(" "))[0]
         }  
      }

    #endregion
 
    #region check logs_timemap.csv and update to csv
 
     $getcsvs = import-csv -path  $rec_csv1
     $getcsvsold = import-csv -path  $rec_csv
 
     foreach($getcsv in $getcsvs){
  
      $mname=$getcsv.MachineName
 
      if($mname -in  $passlist2){
      $newcsv="\\192.168.60.16\srvprj\Inventec\Dell\Matagorda\07.Tool\_AutoTool_Monitor\logs\$($mname)\logs_timemap.csv"
      $lastwt=get-date((gci $newcsv).LastWriteTime) -format "yyyy/M/d HH:mm:ss"
      $checklogs=((import-csv $newcsv).TC).count
       if($checklogs -gt 0){
                
                #add-content -path $errorlog -value "check logs data $newcsv $(get-date)"
                Write-Output "check logs data $newcsv $(get-date)"

                $lastlogs=(import-csv $newcsv)[-1]
                $lastwt=get-date((gci $newcsv).LastWriteTime) -format "yyyy/M/d HH:mm:ss"
 
                $getcsv.Last_TC=$lastlogs."TC"
                $getcsv.Last_Step=$lastlogs."Step_No"
                $getcsv.Last_Program=$lastlogs."program"
                $getcsv.Last_RunTime=$lastwt
              
            }

        else{
            $checklogsold=(($getcsvsold|?{$_.MachineName -eq $mnend}).TC).count
            if($checklogsold -gt 0){

                #add-content -path $errorlog -value "copy failed, keep the same logs data $newcsv $(get-date)"
                Write-Output "copy failed, keep the same logs data $newcsv $(get-date)"

                $getcsv.Last_TC=($getcsvsold|?{$_.MachineName -eq $mnend})."Last_TC"
                $getcsv.Last_Step=($getcsvsold|?{$_.MachineName -eq $mnend})."Last_Step"
                $getcsv.Last_Program=($getcsvsold|?{$_.MachineName -eq $mnend})."Last_Program"
                $getcsv.Last_RunTime=($getcsvsold|?{$_.MachineName -eq $mnend}).Last_RunTim
               
            }
        }
 
     }

 
     }

     $getcsvs|export-csv -path  $rec_csv -NoTypeInformation
  
     remove-item -Path $rec_csv0 -Force
     remove-item -Path $rec_csv1 -Force

     $getcsvs = import-csv -path  $rec_csv
       #remove old folder
     (gci "\\192.168.60.16\srvprj\Inventec\Dell\Matagorda\07.Tool\_AutoTool_Monitor\logs\*" -Directory)|?{
     if( !($_.name -in ($getcsvs.MachineName))){
     remove-item $_.FullName -Recurse -Force
     }
 
     }
 
  
     #endregion update current status to csv
  
 
          #region update html
  
        #---RemoteUpdate----------

        $data2= import-csv $scriptRoot\start_records.csv| ConvertTo-Json | ConvertFrom-Json
        $columnnms= $data2[0].psobject.Properties.Name

        $Data= import-csv $scriptRoot\start_records.csv

        #--------RemoteDetect--------------------------------------------------------------
        $html = Get-Content -Path "$scriptRoot\example.html"
        $titles = @("Select") + $columnnms



        for($i = 0; $i -le $titles.Length-1; $i++){
            $html = $html -replace "examtitle$i\b"  , $titles[$i]
        }

        #adding HTML table row
        $id = 0

        $insertdata = ""
        foreach($D in $Data)
        {

            if($faillist -eq $D.MachineName){
                $insertdata+= "<tr>"
                #$insertdata+= "<td><input id='Remote$id' type='button' value='Connect'  disabled/>Failed</td>"
                $insertdata+= "<td><input id='Remote$id' type='button' value='Connect' />Failed</td>"
            }else{
                $insertdata+= "<tr>"
                $insertdata+= "<td><input id='Remote$id' type='button' value='Connect' /></td>"
            }


            foreach($col in $columnnms){

                if($col -eq "log_folder"){
                    if($faillist -eq $D.MachineName){
                        $insertdata+= "<td> <a id='explorer$id' href='$($D.$col)' style='color:gray; text-decoration: none; cursor: not-allowed; pointer-events: none;'>$($D.$col)</a></td>"                 
                    }else{
                        $insertdata+= "<td> <a id='explorer$id' href='$($D.$col)'>$($D.$col)</a></td>"
                    }
                

                }
                else{
                    $insertdata+= "<td> $($D.$col) </td>"
                }  
            }
            $insertdata+= "</tr>"
            $id +=1
        }

        $html = $html[0..$html.IndexOf("<tbody>")] + $insertdata + $html[($html.IndexOf("</tbody>")-1)..$html.Length]

        $html | Set-Content "$scriptRoot\interface.html"

        #endregion update html


        if(!$electronstatus){
            npm start
        }
    
}
else{
    Write-Output "fail to load start_records.txt"
      Write-Output "it will exit this program after 30s"
     start-sleep -s 30
     
      exit
}

