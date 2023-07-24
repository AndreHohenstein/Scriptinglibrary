try {
# Install Windows UI Library
$version = [Environment]::OSVersion.Version.ToString(2)
$build   = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ReleaseId
$OSName  = ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" )  |
               Where-Object {$_.ProductName -like "Windows 10*" -or $_.ProductName -like "Windows Server 2022*"}).ProductName

    if ($version -ge "10.0") {
      if ($build -ge "1809") {
        if ($OSName -like "Windows 10*" -or $OSName -like "Windows Server 2022*") {
           # Current Windows Terminal version with PS Core
           Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
           $msUILiboff = (Get-AppxPackage Microsoft.UI.Xaml.2.8).version
           }
      }
   }
} catch {
      Write-Host $_.Exception.Messege
     exit 1
}

# getting latest Windows UI Library
$url             = 'https://github.com/microsoft/microsoft-ui-xaml/releases/latest'
$request         = [System.Net.WebRequest]::Create($url)
$response        = $request.GetResponse()
$realTagUrl      = $response.ResponseUri.OriginalString
$version         = $realTagUrl.split('/')[-1].Trim('v')
$msUILibon        = $version.Substring(0,3)
$fileName        = "Microsoft.UI.Xaml.$msUILibon.x64.appx"
$realDownloadUrl = $realTagUrl.Replace('tag', 'download') + '/' + $fileName

# check and install Windows UI Library package

if ([string]"$msUILiboff" -ge [string]"$version") {

    Write-Host "Your Installed Windows UI Library packages :"$($msUILiboff)"is equal or greater than $($version)" -ForegroundColor Green

} else {

    Write-Host "Download Windows UI Library packages $($version)" -ForegroundColor Green

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($realDownloadUrl, $env:USERPROFILE+ "\Downloads\$fileName")

    Start-Sleep -Seconds 5

    # CheckSum
    $msUILibonhash  = (Get-FileHash -InputStream ($webClient.OpenRead($realDownloadUrl))).Hash
    $msUILiboffhash = (Get-FileHash -Path $env:USERPROFILE\Downloads\$fileName).Hash

    # Compute the hash value of a stream and verify the local file
    if ($msUILibonhash  -eq $msUILiboffhash) {

       Write-Host "CheckSum OK" -ForegroundColor Green

       Write-Host "Install Windows UI Library packages $($($version))" -ForegroundColor Green

       Add-AppxPackage -Path $env:USERPROFILE\Downloads\$fileName
       Start-Sleep -Seconds 1
   }
}