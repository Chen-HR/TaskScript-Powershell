# usage: Coder-Base64 Encode-File ${Source}
# usage: Coder-Base64 Decode-File ${Source}
$ActionList = @("encode-file", "decode-file")

$Action = $args[0]
$Source = $args[1]
# $Target = $args[2]

# Filter invalid actions
if ( $Action ) { $Action = $Action.ToLower() } else { $Action = "" }
if ( $Action -eq "" -or ( $ActionList.IndexOf($Action) -eq -1 )) 
  { 
    Write-Error "Error: no action to perform" ;
    Exit 1 ;
  }

if ( $Action -eq "Encode-File" )
  {
    [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($(Get-Content -Raw $Source))) | Write-Output
  }
if ( $Action -eq "Decode-File" )
  {
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(Get-Content $Source))) | Write-Output
  }