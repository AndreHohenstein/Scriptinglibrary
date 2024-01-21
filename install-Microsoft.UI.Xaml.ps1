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

# Download Cascadia Code font from GitHub
$CascadiaURL        = 'https://github.com/microsoft/cascadia-code/releases/latest'
$Cascadiarequest    = [System.Net.WebRequest]::Create($CascadiaURL)
$Cascadiaresponse   = $Cascadiarequest.GetResponse()
$realTagUrl         = $Cascadiaresponse.ResponseUri.OriginalString
$Cascadiaon         = $realTagUrl.split('/')[-1].Trim('v')
$CascadiafileName   = "CascadiaCode-"+"$Cascadiaon"+".zip"
$realCascadiaUrl    = $realTagUrl.Replace('tag', 'download') + '/' + $CascadiafileName

Write-Host "Cascadia Code font $($Cascadiaon)" -ForegroundColor Green

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($realCascadiaUrl, $env:USERPROFILE+ "\Downloads\$CascadiafileName")

# Expanding the font archive file
$FontFolder = $env:USERPROFILE +"\Downloads" +"\Fonts"
if(!(Test-Path $FontFolder)) { New-Item -ItemType Directory -Path $FontFolder | Out-Null}
Expand-Archive -Path $env:USERPROFILE\Downloads\$CascadiafileName -DestinationPath $FontFolder -Force

# Installing the Cascadia Code font
$FontFile = $FontFolder +"\ttf" + "\CascadiaCode.ttf"
$Font = New-Object -Com Shell.Application
$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
$Destination.CopyHere($FontFile,0x10)


Start-Sleep -Seconds 3

# ! delete downloaded files:
Remove-Item -Path $Path,$env:USERPROFILE\Downloads\$msUI,$FontFolder,$env:USERPROFILE\Downloads\$CascadiafileName -Recurse -Confirm:$false
