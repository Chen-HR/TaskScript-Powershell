# usage: Task-Infomation ${Action} ${Name}
# usage: Task-Infomation help
# usage: Task-Infomation time ${Name}
# usage: Task-Infomation infomation ${Name} ${Infomation}
# usage: Task-Infomation source ${Name} ${Infomation} ${Source}
# usage: Task-Infomation target ${Name} ${Infomation} ${Target}
# usage: Task-Infomation sourceTarget ${Name} ${Infomation} ${Source} ${Target}
# usage: Task-Infomation map ${Name} ${Infomation} (${Key[1]} ${Value[1]} ) ...... 
$Prefix = "  "
$TimeFormat = "yyyy/MM/dd(K)HH:mm:ss.ffff"
$ActionList = @("help", "usage", "time", "information", "source", "target", "sourcetarget", "map", "key-value", "kv")

$Action = $args[0] ;
$Name = $args[1] ;
$Infomation = $args[2] ;
$prefix_ = ""

# Filter invalid actions
if ( $Action ) { $Action = $Action.ToLower() } else { $Action = "" }
if ( $Action -eq "" -or ( $ActionList.IndexOf($Action) -eq -1 )) 
  { 
    Write-Error "Error: no action to perform" ;
    Exit 1 ;
  }

# Display names and enable indentation
if ( $Name ) 
  {
    Write-Host $($Name + ":")
    $prefix_ = $Prefix
  }

# output time forever
Write-Host $($prefix_ + "Time: " + $(Get-Date -Format $TimeFormat))

# perform the corresponding action
if ( $Action -eq "help" -or $Action -eq "usage" )
  {
    Write-Host '$ Task-Infomation ${Action} ${Name}'
    Write-Host '$ Task-Infomation help'
    Write-Host '$ Task-Infomation time ${Name}'
    Write-Host '$ Task-Infomation infomation ${Name} ${Infomation}'
    Write-Host '$ Task-Infomation source ${Name} ${Infomation} ${Source}'
    Write-Host '$ Task-Infomation target ${Name} ${Infomation} ${Target}'
    Write-Host '$ Task-Infomation sourceTarget ${Name} ${Infomation} ${Source} ${Target}'
    Write-Host '$ Task-Infomation map ${Name} ${Infomation} (${Key[1]} ${Value[1]} ) ...... '
  }
if ( $Action -eq "information" -or $Action -eq "source" -or $Action -eq "target" -or $Action -eq "sourceTarget" -or $Action -eq "map" -or $Action -eq "key-value" -or $Action -eq "kv")
  {
    $Information = $args[2]
    if ( $Information -ne "" ) { Write-Host $($prefix_ + "Information: " + $Information) }
  }
if ( $Action -eq "source" -or $Action -eq "sourceTarget" )
  {
    if ( $Action -eq "source" -or $Action -eq "sourceTarget" ) { $Source = $args[3]} 
    Write-Host $($prefix_ + "Source: " + $Source)
  }
if ( $Action -eq "target" -or $Action -eq "sourceTarget" )
  {
    if ( $Action -eq "target" ) { $Target = $args[3]} 
    elseif ( $Action -eq "sourceTarget" ) { $Target = $args[4]} 
    Write-Host $($prefix_ + "Target: " + $Target)
  }
if ( $Action -eq "map" -or $Action -eq "key-value" -or $Action -eq "kv" )
  {
    for ( $index = 3; $index -lt $args.Length; $index += 2)
      {
        $key = $args[$index]
        $value = $args[$index+1]
        Write-Host $($prefix_ + $key + ": " + $value)
      }
  }

Write-Host ""
