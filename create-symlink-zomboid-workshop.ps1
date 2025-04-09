#!/c/Windows/System32/WindowsPowerShell/v1.0/powershell
$FolderPath = $PWD

if (!(Test-Path ".\workshop.txt")) {
  Write-Host "Not in mod folder"
  exit
}

$FolderName = (Get-Item $FolderPath).Name
$FolderNameSpaces = $FolderName -Replace '-', ' '
$FolderNameTitleCase = (Get-Culture).TextInfo.ToTitleCase($FolderNameSpaces) -Replace ' '

New-Item -Path "$env:USERPROFILE\Zomboid\Workshop\$FolderName" -ItemType SymbolicLink -Value $FolderPath
if (Test-Path "$env:USERPROFILE\ZomboidB41") {
  Write-Host "Found B41 cache folder, writting symlink there too"
  New-Item -Path "$env:USERPROFILE\ZomboidB41\mods\$FolderName" -ItemType SymbolicLink -Value "$FolderPath\Contents\mods\Delran$FolderNameTitleCase"
}

