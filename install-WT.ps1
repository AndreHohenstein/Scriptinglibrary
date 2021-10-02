# Install Windows Terminal latest Version
$version = [Environment]::OSVersion.Version.ToString(2)
$build   = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ReleaseId
$OSName  = ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" )  |
               Where-Object {$_.ProductName -like "Windows 10*" -or $_.ProductName -like "Windows Server 2022*"}).ProductName

    if ($version -ge "10.0") {
      if ($build -ge "1809") {
        if ($OSName -like "Windows 10*" -or $OSName -like "Windows Server 2022*") {    

# Current Windows Terminal version with PS Core
Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
$wtoff = (Get-AppxPackage Microsoft.WindowsTerminal).version
  }
 }
}

# getting latest Windows Terminal version from GitHub 
$wturl        = 'https://github.com/microsoft/terminal/releases/latest'
$wtrequest    = [System.Net.WebRequest]::Create($wturl)
$wtresponse   = $wtrequest.GetResponse()
$realTagUrl   = $wtresponse.ResponseUri.OriginalString
$wton         = $realTagUrl.split('/')[-1].Trim('v')
$wtfileName   = "Microsoft.WindowsTerminal_"+"$wton"+"_8wekyb3d8bbwe.msixbundle"
$realwtUrl    = $realTagUrl.Replace('tag', 'download') + '/' + $wtfileName

 # check and install Windows Terminal
 if ([string]"$wtoff" -ne [string]"$wton")
 {Write-Host "Download Windows Terminal $($wton)" -ForegroundColor Green
    
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($realwtUrl, $env:USERPROFILE+ "\Downloads\$wtfileName")
   
   Start-Sleep -Seconds 5

   Write-Host "Install Windows Terminal $($($wton))" -ForegroundColor Green
   Add-AppxPackage -Path $env:USERPROFILE\Downloads\$wtfileName
  }

  if ([string]"$wtoff" -ge [string]"$wton")
  {Write-Host "Your Installed Windows Terminal :"$($wtoff)"is equal or greater than $($wton )" -ForegroundColor Green}
