Write-Host "Run Task Infomation:" 
if ( $args[0] )
  {
    Write-Host "  Name:" $args[0]
  }
if ( $args[1] )
  {
    Write-Host "  Infomation:" $args[1]
  }
if ( $args[2] )
  {
    Write-Host "  Source:" $args[2]
  }
if ( $args[3] )
  {
    Write-Host "  Target:" $args[3]
  }
Write-Host "  Time: $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')"
Write-Host ""
