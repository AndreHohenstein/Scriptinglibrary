# Current Notepad++ version with PS Core
$notepadoff = (Get-ItemProperty -Path $env:ProgramFiles\Notepad++\notepad++.exe -ErrorAction SilentlyContinue).VersionInfo.FileVersion

# getting latest Notepad++ version from GitHub 
# https://github.com/notepad-plus-plus/notepad-plus-plus
$notepadurl      = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest'
$notepadrequest  = [System.Net.WebRequest]::Create($notepadurl)
$notepadresponse = $notepadrequest.GetResponse()
$realTagUrl      = $notepadresponse.ResponseUri.OriginalString
$notepadon       = $realTagUrl.split('/')[-1].Trim('v')
$notepadfilename = "npp.$notepadon.Installer.x64.exe"
$realnotepadUrl = $realTagUrl.Replace('tag', 'download') + '/' + $notepadfilename

# check and install Notepad++
if ([string]"$notepadoff" -ge [string]"$notepadon") {
 
    Write-Host "Your Installed Notepad++ :"$($notepadoff)"is equal or greater than $($notepadon)" -ForegroundColor Green 

} else {

    Write-Host "Download Notepad++ $($notepadon)" -ForegroundColor Green

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($realnotepadUrl, $env:USERPROFILE+ "\Downloads\$notepadfilename")

    Start-Sleep -Seconds 1

    # CheckSum
    $notepadonhash = (Get-FileHash -InputStream ($webClient.OpenRead($realnotepadUrl))).Hash
    $notepadoffhash =  (Get-FileHash -Path "$env:USERPROFILE\Downloads\$notepadfilename").Hash

    # Compute the hash value of a stream and verify the local file
    if ($notepadonhash -eq $notepadoffhash) {

       Write-Host "CheckSum OK" -ForegroundColor Green

       Write-Host "Install Notepad++ $($($notepadon))" -ForegroundColor Green
 
       Start-Process -FilePath "$env:USERPROFILE\Downloads\$notepadfilename" -ArgumentList "/S" -Wait
     
    # ! delete downloaded files:
       Remove-Item -Path "$env:USERPROFILE\Downloads\$notepadfilename" -Force
   }
}
