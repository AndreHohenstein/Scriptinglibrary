try {
# Install Desktop framework packages latest Version
$version = [Environment]::OSVersion.Version.ToString(2)
$build   = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ReleaseId
$OSName  = ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" )  |
               Where-Object {$_.ProductName -like "Windows 10*" -or $_.ProductName -like "Windows Server 2022*"}).ProductName

    if ($version -ge "10.0") {
      if ($build -ge "1809") {
        if ($OSName -like "Windows 10*" -or $OSName -like "Windows Server 2022*") {
           # Current Windows Terminal version with PS Core
           Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
           $vclibsoff = (Get-AppxPackage Microsoft.VCLibs.140.00.UWPDesktop).version
           }
      }
   }
} catch {
      Write-Host $_.Exception.Messege
     exit 1
}

# getting latest Desktop framework packages from Microsoft 
$url             = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$request         = [System.Net.WebRequest]::Create($url)
$response        = $request.GetResponse()
$realVclibsUrl   = $response.ResponseUri.OriginalString
$vclibson        = $realVclibsUrl.split('/')[8].trimend('.0-Desktop')
$vclibsfileName  = "Microsoft.VCLibs.x64.14.00.Desktop.appx"

# check and install Desktop framework packages

if ([string]"$vclibsoff" -ge [string]"$vclibson") {
 
    Write-Host "Your Installed Desktop framework packages :"$($vclibsoff)"is equal or greater than $($vclibson )" -ForegroundColor Green 

} else {

    Write-Host "Download Desktop framework packages $($vclibson)" -ForegroundColor Green

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($realVclibsUrl, $env:USERPROFILE+ "\Downloads\$vclibsfileName")

    Start-Sleep -Seconds 5

    # CheckSum
    $vclibsonhash  = (Get-FileHash -InputStream ($webClient.OpenRead($realVclibsUrl))).Hash
    $vclibsoffhash = (Get-FileHash -Path $env:USERPROFILE\Downloads\$vclibsfileName).Hash

    # Compute the hash value of a stream and verify the local file
    if ($vclibsonhash  -eq $vclibsoffhash) {

       Write-Host "CheckSum OK" -ForegroundColor Green

       Write-Host "Install Desktop framework packages $($($vclibson))" -ForegroundColor Green
 
       Add-AppxPackage -Path $env:USERPROFILE\Downloads\$vclibsfileName
       Start-Sleep -Seconds 1
   }
}