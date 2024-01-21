Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue

# Download Windows UI Library 
$wturl        = 'https://github.com/microsoft/terminal/releases/latest'
$wtrequest    = [System.Net.WebRequest]::Create($wturl)
$wtresponse   = $wtrequest.GetResponse()
$realTagUrl   = $wtresponse.ResponseUri.OriginalString
$wton         = $realTagUrl.split('/')[-1].Trim('v')
$wtfileName   = "Microsoft.WindowsTerminal_"+"$wton"+"_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip"
$realwtUrl    = $realTagUrl.Replace('tag', 'download') + '/' + $wtfileName

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($realwtUrl, $env:USERPROFILE+ "\Downloads\$wtfileName")

Expand-Archive -Path $env:USERPROFILE\Downloads\$wtfileName -DestinationPath $env:USERPROFILE\Downloads\Microsoft.UI

$File = (Get-ChildItem -Path C:\Users\Andre\Downloads\UI | Where-Object {$_.Name -match "x64"}).Name

Add-AppPackage -Path "$env:USERPROFILE\Downloads\Microsoft.UI\$file"
