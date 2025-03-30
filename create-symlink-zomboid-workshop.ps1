#!/c/Windows/System32/WindowsPowerShell/v1.0/powershell
$FolderPath = $PWD

if (!(Test-Path ".\workshop.txt")) {
  Write-Host "Not in mod folder"
  exit
}

$FolderName = (Get-Item $FolderPath).Name

New-Item -Path "$env:USERPROFILE\Zomboid\Workshop\$FolderName" -ItemType SymbolicLink -Value $FolderPath

