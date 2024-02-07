Import-Module Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
           $vclibsoff = (Get-AppxPackage Microsoft.VCLibs.140.00.UWPDesktop).version

# getting latest Desktop framework packages from Microsoft 
$url             = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$request         = [System.Net.WebRequest]::Create($url)
$response        = $request.GetResponse()
$realVclibsUrl   = $response.ResponseUri.OriginalString
$vclibson        = $realVclibsUrl.split('/')[8].trimend('.0-Desktop')
$vclibsfileName  = "Microsoft.VCLibs.x64.14.00.Desktop.appx"

# check and install Desktop framework packages

if ($null -ne $vclibsoff) { Write-Host "The Desktop framework packages Version:`t$($vclibsoff) is already exists" -ForegroundColor Green }

else {

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
 
       Add-AppxPackage -Path "$env:USERPROFILE\Downloads\$vclibsfileName"
       Start-Sleep -Seconds 1

    # ! delete downloaded files:
       Remove-Item -Path "$env:USERPROFILE\Downloads\$vclibsfileName" -Force
   }
}
