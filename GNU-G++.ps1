# Note: FileExtension: ".cpp"
# Usage: GNU-G++.ps1 {Action} {FileBasenameNoExtension} {Folder}
$Action = $args[0] ;
$FileBasenameNoExtension = $args[1] ;
$Folder = $args[2] ;

if ( $Action ) { $Action = $Action.ToLower() } else { $Action = "" }
if ( -not $FileBasenameNoExtension ) { $FileBasenameNoExtension = "" }
if ( -not $Folder ) { $Folder = "." }

$File = $Folder + "/" + $FileBasenameNoExtension

if ( $Action -eq "" -or ( $Action -ne "build" -and $Action -ne "compile" -and $Action -ne "test"  -and $Action -ne "test-flush" )) 
  { 
    Write-Error "Error: no action to perform" ;
    Exit 1 ;
  }
if ( $FileBasenameNoExtension -eq "" ) 
  { 
    Write-Error "Error: no files to process" ;
    Exit 1 ;
  }
# if ( $Folder -eq "" ) { Break; }

Write-Host "Running Information: " ;
Write-Host "  Time: $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" ; ;
Write-Host "  Action: $Action" ;
Write-Host "  File: $File.cpp" ;
Write-Host "  Folder: $Folder" ;
Write-Host "" ;

# Pre-Compilation Processing
if ( $Action -eq "build" -or $Action -eq "test-flush" )
  {
    Write-Host "Action: Pre-Compilation Processing";
    Write-Host "  Time: $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" ;
    Write-Host "  File: $File.cpp" ; 
    if ( Test-Path "$File.exe" )
      {
        Write-Host "  Statue: Remove File: '$File.exe'" ; 
        Remove-Item "$File.exe" ;
      }
    Write-Host "" ; 
  }

# Use: "$File.Compile.Options.txt"
# Generate: "$File.Preprocessing.cpp", "$File.Compile.Command.ps1"
if ( $Action -eq "build" -or $Action -eq "compile" -or $Action -eq "test" -or $Action -eq "test-flush" )
  {
    Write-Host "Action: Compile";
    Write-Host "  Time: $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" ;
    Write-Host "  File: $File.cpp" ; 
    # Write-Host "" ; 
    # Check File is changed
    $FileChanged = $True ;
    Invoke-Expression "g++ -E -P $File.cpp -o $File.Preprocessing.cpp"
    if ( Test-Path "$File.Preprocessing.Hash" ) 
      {
        if (( $( Get-FileHash "$File.Preprocessing.cpp" -Algorithm SHA256 ).Hash.ToString() -eq $( Get-Content "$File.Preprocessing.Hash" -Raw) ) -and ( Test-Path "$File.exe" ))
          {
            Write-Host "  State: file unchanged" ;
            $FileChanged = $False ;
          }
        else 
          {
            Write-Host "  State: file changed" ;
          }
      }
    if ( -not (Test-Path "$File.exe") )
      {
        Write-Host "  State: executable file does not exist" ;
        $FileChanged = $True ;
      }
    if ( $FileChanged ) 
      {
        # Remove Execute File
        if ( Test-Path "$File.exe" )
          {
            Write-Host "  Statue: Remove File: '$File.exe'" ; 
            Remove-Item "$File.exe" ;
          }
        # Create file hash value
        Write-Host "  State: Create file hash" ;
        $( Get-FileHash "$File.Preprocessing.cpp" -Algorithm SHA256 ).Hash | Out-File -FilePath "$File.Preprocessing.Hash" -NoNewline ;
        # Build compile command
        $Command = "g++ $File.cpp -o $File.exe" ;
        if ( Test-Path "$File.Compile.Options.txt") 
          {
            $Command += " " + $( Get-Content "$File.Compile.Options.txt" -Raw)
          }
        "# Create this file and run at $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" | Out-File -FilePath "$File.Compile.Command.ps1" ; 
        "$Command ;" | Out-File -FilePath "$File.Compile.Command.ps1" -Append -NoNewline ;
        Write-Host "  Command: $Command" ;
        Invoke-Expression $Command
      }
    Write-Host "" ; 
  }

# Use: "$File.Execute.Argument.txt", "$File.Execute.Input.txt", "$File.Execute.Output.txt", "$File.Execute.OutputHistory.txt"
# Generate: "$File.Preprocessing.cpp", "$File.Compile.Command.ps1"
if ( $Action -eq "test" -or $Action -eq "test-flush" )
  {
    Write-Host "Action: Execute";
    Write-Host "  Time: $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" ;
    Write-Host "  File: $File.exe" ; 
    $Command = "$File.exe" ;
    if ( Test-Path $Command )
      {
        if ( Test-Path "$File.Execute.Argument.txt" ) { $Command += " " + $( Get-Content "$File.Execute.Argument.txt" -Raw) }
        if ( Test-Path "$File.Execute.Input.txt" ) { $Command = "Get-Content $File.Execute.Input.txt -Raw" + " | " + $Command }
        if ( Test-Path "$File.Execute.Output.txt" ) { $Command += " > " + "$File.Execute.Output.txt" }
        "# Create this file and run at $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" | Out-File -FilePath "$File.Execute.Command.ps1" ; 
        "$Command ;" | Out-File -FilePath "$File.Execute.Command.ps1" -Append -NoNewline ;
        Write-Host "  Command: $Command" ; 
        Write-Host "" ; 
        Invoke-Expression $Command ;
        if ( Test-Path "$File.Execute.OutputHistory.txt" ) 
          { 
            "$ Run at $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" | Out-File -FilePath "$File.Execute.OutputHistory.txt" -Append ; 
            $( Get-Content "$File.Execute.Output.txt" -Raw) | Out-File -FilePath "$File.Execute.OutputHistory.txt" -Append ; 
          }
      }
    else 
      {
        Write-Error "Error: Archive has not finished compiling" ;
      }
    Write-Host "" ; 
  }
  
# Post-Processing
if ( $Action -eq "test-flush" )
{
  Write-Host "Action: Post-Processing";
  Write-Host "  Time: $(Get-Date -Format 'yyyy/MM/dd(K)HH:mm:ss.ffff')" ;
  Write-Host "  File: $File.cpp" ; 
  if ( Test-Path "$File.exe" )
    {
      Write-Host "  Statue: Remove File: '$File.exe'" ; 
      Remove-Item "$File.exe" ;
    }
  Write-Host "" ; 
}
