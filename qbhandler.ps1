param ([string]$torrentPath)

# CONFIGURATION
$qbUrl  = "http://torrent:8080"
$username = "admin"
$password = "..."

if ($torrentPath) {
    $torrentPath = $torrentPath.Trim('"')
} else {
    Write-Error "No torrent path provided."
    exit 1
}

# DETERMINE CONTENT LAYOUT
if ($torrentPath -like "*.mkv.torrent" -or $torrentPath -like "*.avi.torrent" -or $torrentPath -like "*.mp4.torrent") {
    $contentLayout = "Subfolder"
    Write-Host "Using Subfolder layout"
}
else {
    $contentLayout = "Original"
    Write-Host "Using Original layout"
}

# AUTH
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-WebRequest -Uri "$qbUrl/api/v2/auth/login" `
    -Method Post `
    -Body @{ username = $username; password = $password } `
    -WebSession $session

if ($login.Content -ne "Ok.") {
    Write-Error "Login failed."
    exit 1
} 

# FILE PREP
$boundary = "----WebKitFormBoundary$(Get-Random)"
$LF = "`r`n"
$filename = [System.IO.Path]::GetFileName($torrentPath)
$fileBytes = [System.IO.File]::ReadAllBytes($torrentPath)

# BUILD BODY
$bodyBuilder = New-Object System.Text.StringBuilder

# Field: contentLayout
$bodyBuilder.Append("--$boundary$LF") | Out-Null
$bodyBuilder.Append("Content-Disposition: form-data; name=`"contentLayout`"$LF$LF") | Out-Null
$bodyBuilder.Append("$contentLayout$LF") | Out-Null

# Field: torrents (the file)
$bodyBuilder.Append("--$boundary$LF") | Out-Null
$bodyBuilder.Append("Content-Disposition: form-data; name=`"torrents`"; filename=`"$filename`"$LF") | Out-Null
$bodyBuilder.Append("Content-Type: application/x-bittorrent$LF$LF") | Out-Null

# === COMBINE BODY ===
$preBytes = [System.Text.Encoding]::ASCII.GetBytes($bodyBuilder.ToString())
$postBytes = [System.Text.Encoding]::ASCII.GetBytes("$LF--$boundary--$LF")

$fullBody = New-Object System.IO.MemoryStream
$fullBody.Write($preBytes, 0, $preBytes.Length)
$fullBody.Write($fileBytes, 0, $fileBytes.Length)
$fullBody.Write($postBytes, 0, $postBytes.Length)
$fullBody.Seek(0, 'Begin') | Out-Null

# SEND TORRENT
Invoke-WebRequest -Uri "$qbUrl/api/v2/torrents/add" `
    -Method Post `
    -WebSession $session `
    -Headers @{ "Content-Type" = "multipart/form-data; boundary=$boundary" } `
    -Body $fullBody

Write-Host "Torrent added: $torrentFileName"
