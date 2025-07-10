# qbhandler

Handler for .torrent files in Windows that uses the qbittorrent API to add the torrent for download. It also inspects the torrent file structure to determine if it should add a subfolder or not.

## Installation

1. Install Python and the requests library (`pip install requests bencodepy`)
2. Run `register.ps1` once to set up the file association
3. Double-click a .torrent and confirm choice of application

## Usage

Double-clicking or downloading .torrent files will add them to qbittorrent, 

## History

First version was written in powershell and is included in this repo, but as powershell 5 is the default in Windows 11 I had a hard time to getting inspection of the torrent file working. Everything works better with bencodepy.

## Files

### Python version

```
qbhandler.py
qbhandler.cmd
register.ps1
```

### Powershell version

```
qbhandler.ps1
qbhandler.bat
register.ps1
```
