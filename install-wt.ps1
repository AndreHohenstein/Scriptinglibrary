try {
# You must be running Windows 10 2004 (build >= 10.0.19041.0) or later
# Install Windows Terminal latest Version 
$version = [Environment]::OSVersion.Version.ToString(2)
$build   = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CurrentBuild
$OSName  = ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" )  |
               Where-Object {$_.ProductName -like "Windows 10*" -or $_.ProductName -like "Windows Server 2022*"}).ProductName
$caption = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption

    if ($version -ge "10.0") {
      if ($build -ge "19041") {
        if ($OSName -like "Windows 10*" -or $OSName -like "Windows Server 2022*") {
           # Current Windows Terminal version with PS Core
           Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
           $wtoff = (Get-AppxPackage Microsoft.WindowsTerminal).version 
           }
      }
   }
} catch {
      Write-Host $_.Exception.Messege
     exit 1
}

# getting latest Windows Terminal version from GitHub 
$wturl        = 'https://github.com/microsoft/terminal/releases/latest'
$wtrequest    = [System.Net.WebRequest]::Create($wturl)
$wtresponse   = $wtrequest.GetResponse()
$realTagUrl   = $wtresponse.ResponseUri.OriginalString
$wton         = $realTagUrl.split('/')[-1].Trim('v')
$wtfileName   = "Microsoft.WindowsTerminal_Win10_"+"$wton"+"_8wekyb3d8bbwe.msixbundle"
$realwtUrl    = $realTagUrl.Replace('tag', 'download') + '/' + $wtfileName

# check and install Windows Terminal
$caption = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
if ($caption -like "Microsoft Windows 10*" -or $caption -like "Microsoft Windows Server 2022*"){

if ([string]"$wtoff" -ge [string]"$wton") {
 
    Write-Host "Your Installed Windows Terminal :"$($wtoff)"is equal or greater than $($wton )" -ForegroundColor Green 

} else {

    Write-Host "Download Windows Terminal $($wton)" -ForegroundColor Green

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($realwtUrl, $env:USERPROFILE+ "\Downloads\$wtfileName")

    Start-Sleep -Seconds 5

    # CheckSum
    $wtonhash = (Get-FileHash -InputStream ($webClient.OpenRead($realwtUrl))).Hash
    $wtoffhash =  (Get-FileHash -Path $env:USERPROFILE\Downloads\$wtfileName).Hash

    # Compute the hash value of a stream and verify the local file
    if ($wtonhash -eq $wtoffhash) {

       Write-Host "CheckSum OK" -ForegroundColor Green

       Write-Host "Install Windows Terminal $($($wton))" -ForegroundColor Green
 
       Add-AppxPackage -Path $env:USERPROFILE\Downloads\$wtfileName
       Start-Sleep -Seconds 1
   }
}}

Write-Host "Please wait for the Windows Terminal Profile..." -ForegroundColor Green
# Windows Terminal Settings Location
$wtjsonpath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

$ProgressPreference = 'SilentlyContinue' 
# Apply my customized Windows Terminal Settings from GitHub
$wtprofilesurl = 'https://raw.githubusercontent.com/AndreHohenstein/Scriptinglibrary/main/WindowsTerminalSettings/profiles.json'
Invoke-WebRequest -Uri $wtprofilesurl -OutFile $wtjsonpath
Start-Sleep -Seconds 1


# Check if Folder for Windows Terminal Resources exists
$wtFolfer = $env:USERPROFILE+"\pictures\wt" 
if(!(Test-Path -Path $wtFolfer -PathType Container)){New-Item -ItemType Directory -Path $wtFolfer | Out-Null}

# Download Windows Terminal Resources
$AzureCloudShellUrl = 'https://raw.githubusercontent.com/AndreHohenstein/Scriptinglibrary/main/WindowsTerminalSettings/resources/AzureCloudShell.png'
$BlackCloudRobotUrl = 'https://raw.githubusercontent.com/AndreHohenstein/Scriptinglibrary/main/WindowsTerminalSettings/resources/BlackCloudRobot.png'
$PSCoreAvatar       = 'https://raw.githubusercontent.com/AndreHohenstein/Scriptinglibrary/main/WindowsTerminalSettings/resources/PSCoreAvatar.png'

Invoke-WebRequest -Uri $AzureCloudShellUrl -OutFile $env:USERPROFILE\pictures\wt\AzureCloudShell.png
Invoke-WebRequest -Uri $BlackCloudRobotUrl -OutFile $env:USERPROFILE\pictures\wt\BlackCloudRobot.png
Invoke-WebRequest -Uri $PSCoreAvatar -OutFile $env:USERPROFILE\pictures\wt\PSCoreAvatar.png

# open Windows Terminal from Powershell
Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
Get-AppxPackage *terminal* | % {& Explorer.exe $('Shell:AppsFolder\' + $_.PackageFamilyName + '!' + $((Get-AppxPackageManifest $_.PackageFullName).Package.Applications.Application.id))}

