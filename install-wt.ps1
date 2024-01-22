Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
$wtoff = (Get-AppxPackage Microsoft.WindowsTerminal).version 

# getting latest Windows Terminal version from GitHub 
$wturl        = 'https://github.com/microsoft/terminal/releases/latest'
$wtrequest    = [System.Net.WebRequest]::Create($wturl)
$wtresponse   = $wtrequest.GetResponse()
$realTagUrl   = $wtresponse.ResponseUri.OriginalString
$wton         = $realTagUrl.split('/')[-1].Trim('v')
$wtfileName   = "Microsoft.WindowsTerminal_"+"$wton"+"_8wekyb3d8bbwe.msixbundle"
$realwtUrl    = $realTagUrl.Replace('tag', 'download') + '/' + $wtfileName

# check and install Windows Terminal
if ([string]"$wtoff" -ge [string]"$wton") {
 
    Write-Host "Your Installed Windows Terminal :"$($wtoff)"is equal or greater than $($wton )" -ForegroundColor Green 
}
 else {

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
 
       Add-AppxPackage -Path "$env:USERPROFILE\Downloads\$wtfileName"
       
       Start-Sleep -Seconds 1

       # ! delete downloaded files:
       Remove-Item -Path "$env:USERPROFILE\Downloads\$wtfileName" -Force
   }
}


# Windows Terminal Settings Location
$wtjsonpath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$WSProfile = get-Content -Path $wtjsonpath | Where-Object { ($_ -match "AHCT")}

if ($WSProfile) {Write-Host "The Windows Terminal Profile allready exists" -ForegroundColor Green}

else {

$ProgressPreference = 'SilentlyContinue' 
# Apply my customized Windows Terminal Settings from GitHub
Write-Host "Apply my customized Windows Terminal Settings from GitHub" -ForegroundColor Green
$wtprofilesurl = 'https://raw.githubusercontent.com/AndreHohenstein/Scriptinglibrary/main/WindowsTerminalSettings/profiles.json'
Invoke-WebRequest -Uri $wtprofilesurl -OutFile $wtjsonpath

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

}

Start-Sleep -Seconds 1


# open Windows Terminal from Powershell
#Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
#Get-AppxPackage *terminal* | % {& Explorer.exe $('Shell:AppsFolder\' + $_.PackageFamilyName + '!' + $((Get-AppxPackageManifest $_.PackageFullName).Package.Applications.Application.id))}
