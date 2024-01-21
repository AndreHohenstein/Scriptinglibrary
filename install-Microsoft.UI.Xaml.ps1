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
# check installed fonts
$regEntryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'

# Grab the property
$property = (Get-ItemProperty -Path $regEntryPath).CascadiaCode

# Test if property exists
if ($null -ne $property) { Write-Host "The Font $($property) is already exists" -ForegroundColor Green }
else 
{
# Download Cascadia Code font from GitHub
$CascadiaURL        = 'https://github.com/microsoft/cascadia-code/releases/latest'
$Cascadiarequest    = [System.Net.WebRequest]::Create($CascadiaURL)
$Cascadiaresponse   = $Cascadiarequest.GetResponse()
$realTagUrl         = $Cascadiaresponse.ResponseUri.OriginalString
$Cascadiaon         = $realTagUrl.split('/')[-1].Trim('v')
$CascadiafileName   = "CascadiaCode-"+"$Cascadiaon"+".zip"
$realCascadiaUrl    = $realTagUrl.Replace('tag', 'download') + '/' + $CascadiafileName

Write-Host "Download Font CascadiaCode Version:`t$($Cascadiaon)" -ForegroundColor Green

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($realCascadiaUrl, $env:USERPROFILE+ "\Downloads\$CascadiafileName")


$FontFolder = $env:USERPROFILE +"\Downloads" +"\Fonts" +"\ttf"
$FontItem = Get-Item -Path $FontFolder
$FontList = Get-ChildItem -Path "$FontItem\*" -Include ("CascadiaCode.ttf")

foreach ($Font in $FontList) {
        Write-Host 'Installing Font -' $Font.BaseName -ForegroundColor Green
        Copy-Item $Font "C:\Windows\Fonts" -Force
        New-ItemProperty -Name $Font.BaseName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $Font.name         
 }
}

Start-Sleep -Seconds 3

# ! delete downloaded files:
Remove-Item -Path $Path,$env:USERPROFILE\Downloads\$msUI,$FontFolder,$env:USERPROFILE\Downloads\$CascadiafileName -Recurse -Confirm:$false
