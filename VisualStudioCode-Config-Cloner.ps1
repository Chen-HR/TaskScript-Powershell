# usage: VisualStudioCode-Config-Cloner ${Action} ${Target} ${Source}
$TimeFormat = "yyyy/MM/dd(K)HH:mm:ss.ffff"
$ActionList = @("current", "git-clone")

$Action = $args[0]
$Target = $args[1]
$Source = $args[2]

# Filter invalid actions
if ( $Action ) { $Action = $Action.ToLower() } else { $Action = "" }
if ( $Action -eq "" -or ( $ActionList.IndexOf($Action) -eq -1 )) 
  { 
    Write-Error "Error: no action to perform" ;
    Exit 1 ;
  }

"# Create this file and run at $(Get-Date -Format $TimeFormat)" | Out-File -FilePath "$Target\VisualStudioCode-Config-Cloner.ps1" ;
if ( $Action -eq "current" )
  {
    "Copy-Item -Path '$Source\.vscode' -Destination '$Target' -Recurse ; " | Out-File -FilePath "$Target\VisualStudioCode-Config-Cloner.ps1" -Append ;
  }
if ( $Action -eq "git-clone" )
  {
    "& git clone $Source $Target/.vscode --quiet" | Out-File -FilePath "$Target\VisualStudioCode-Config-Cloner.ps1" -Append ;
  }
"Move-Item -Path '$Target\.vscode\*.code-workspace\' -Destination '$Target\.vscode\$($Target.Split('\')[-1]).code-workspace' ; " | Out-File -FilePath "$Target\VisualStudioCode-Config-Cloner.ps1" -Append ;
# Get-Content "$Target\VisualStudioCode-Config-Cloner.ps1" ;
& "$Target\VisualStudioCode-Config-Cloner.ps1" ;
