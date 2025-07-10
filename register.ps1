#
# Register .torrent files handler
#

$extension = ".torrent"
$progPath = "c:\users\km\git\qbhandler\qbhandler.cmd"
$progId = "HandleTorrentScript"

# Register handler
New-Item -Path "HKCU:\Software\Classes\$progId" -Force
Set-ItemProperty -Path "HKCU:\Software\Classes\$progId" -Name "FriendlyTypeName" -Value "Torrent Handler"
New-Item -Path "HKCU:\Software\Classes\$progId\shell\open\command" -Force
Set-ItemProperty -Path "HKCU:\Software\Classes\$progId\shell\open\command" -Name "(default)" -Value "`"$progPath`" `"%1`""

# Associate .torrent
New-Item -Path "HKCU:\Software\Classes\$extension" -Force
Set-ItemProperty -Path "HKCU:\Software\Classes\$extension" -Name "(default)" -Value $progId

