try {
# Install Windows UI Library
$OSName  = ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" )  |
               Where-Object {$_.ProductName -like "Windows Server 2022*"}).ProductName

        if ($OSName -like "Windows Server 2022*") {
           # Current Windows Terminal version with PS Core
           Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
    }

} catch {
      Write-Host $_.Exception.Messege
     exit 1
}

# Download Windows UI Library 2.7.3
$ProgressPreference = 'SilentlyContinue'
$url                = 'https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3'
Invoke-WebRequest -Uri $url -OutFile $env:USERPROFILE\Downloads\Microsoft.UI.Xaml.2.7.3.zip
Expand-Archive -Path $env:USERPROFILE\Downloads\Microsoft.UI.Xaml.2.7.3.zip -DestinationPath .\Microsoft.UI.Xaml.2.7.3
Add-AppPackage -Path "$env:USERPROFILE\Downloads\Microsoft.UI.Xaml.2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx"
