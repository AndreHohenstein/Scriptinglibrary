Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue

# Download Windows UI Library 
$wturl        = 'https://github.com/microsoft/terminal/releases/latest'
$wtrequest    = [System.Net.WebRequest]::Create($wturl)
$wtresponse   = $wtrequest.GetResponse()
$realTagUrl   = $wtresponse.ResponseUri.OriginalString
$wton         = $realTagUrl.split('/')[-1].Trim('v')
$msUI   = "Microsoft.WindowsTerminal_"+"$wton"+"_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip"
$realwtUrl    = $realTagUrl.Replace('tag', 'download') + '/' + $msUI

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($realwtUrl, $env:USERPROFILE+ "\Downloads\$msUI")

$Path = $env:USERPROFILE +"\Downloads\" +"\Microsoft.UI"
if(!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null} 

Expand-Archive -Path $env:USERPROFILE\Downloads\$msUI -DestinationPath $Path -Force

$File = (Get-ChildItem -Path $Path | Where-Object {$_.Name -match "x64"}).Name

Add-AppPackage -Path $Path\$File
Start-Sleep -Seconds 3

# ! delete downloaded files:
Remove-Item -Path $Path,$env:USERPROFILE\Downloads\$msUI -Recurse -Confirm:$false
