# Note: FileExtension: ".cpp"
# Usage: GNU-G++.ps1 {Compiler} {Action} {FileBasenameNoExtension} {Folder}
$ActionList = @("preprocess", "build", "compile", "test", "test-flush")
$Prefix = "  - "
$TimeFormat = "yyyy/MM/dd(K)HH:mm:ss.ffff"

$Compiler = $args[0] ;
$Action = $args[1] ;
$FileBasenameNoExtension = $args[2] ;
$Folder = $args[3] ;

if ( $Compiler ) { $Compiler = $Compiler } else { $Compiler = "" }
if ( $Action ) { $Action = $Action.ToLower() } else { $Action = "" }
if ( -not $FileBasenameNoExtension ) { $FileBasenameNoExtension = "" }
if ( -not $Folder ) { $Folder = "." }

$File = $Folder + "/" + $FileBasenameNoExtension

if ( $Compiler -eq "" -or ( $Compiler.IndexOf($Action) -eq -1 )) 
  { 
    Write-Error "Error: no compiler to perform" ;
    Exit 1 ;
  }
if ( $Action -eq "" -or ( $ActionList.IndexOf($Action) -eq -1 )) 
  { 
    Write-Error "Error: no action to perform" ;
    Exit 1 ;
  }
if ( $FileBasenameNoExtension -eq "" ) 
  { 
    Write-Error "Error: no files to process" ;
    Exit 1 ;
  }

Write-Host "Running Information: " ;
Write-Host $($Prefix + "Time: $(Get-Date -Format $TimeFormat)") ;
Write-Host $($Prefix + "Action: $Action") ;
Write-Host $($Prefix + "File: $File.cpp") ;
Write-Host $($Prefix + "Folder: $Folder") ;
if (!(Test-Path "$File/")) 
  {
    $null = New-Item -ItemType Directory -Path "$File/"
    Write-Host $($Prefix + "Folder created: $File/")
  } 
if (!(Test-Path "$File/Compile/")) 
  {
    $null = New-Item -ItemType Directory -Path "$File/Compile/"
    Write-Host $($Prefix + "Folder created: $File/Compile/")
  } 
if (!(Test-Path "$File/Execute/")) 
  {
    $null = New-Item -ItemType Directory -Path "$File/Execute/"
    Write-Host $($Prefix + "Folder created: $File/Execute/")
  } 
if (!(Test-Path "$File/Compile/Options.txt")) 
  {
    $null = New-Item -ItemType File -Path "$File/Compile/Options.txt"
    Write-Host $($Prefix + "File created: $File/Compile/Options.txt")
  } 
if (!(Test-Path "$File/Execute/Argument.txt")) 
  {
    $null = New-Item -ItemType File -Path "$File/Execute/Argument.txt"
    Write-Host $($Prefix + "File created: $File/Execute/Argument.txt")
  } 
Write-Host "" ;

# Pre-Compilation Processing
if ( $Action -eq "build" -or $Action -eq "test-flush" )
  {
    Write-Host "Action: Pre-Compilation Processing";
    Write-Host $($Prefix + "Time: $(Get-Date -Format $TimeFormat)") ;
    Write-Host $($Prefix + "File: $File.cpp") ; 
    if ( Test-Path "$File/$FileBasenameNoExtension.exe" )
      {
        Write-Host $($Prefix + "Statue: Remove File: '$File/$FileBasenameNoExtension.exe'") ; 
        Remove-Item "$File/$FileBasenameNoExtension.exe" ;
      }
    Write-Host "" ; 
  }

# Expand Preprocess
if ( $Action -eq "preprocess" -or $Action -eq "build" -or $Action -eq "compile" -or $Action -eq "test" -or $Action -eq "test-flush")
  {
    Write-Host "Action: Expand Preprocess";
    Write-Host $($Prefix + "Time: $(Get-Date -Format $TimeFormat)") ;
    Write-Host $($Prefix + "File: $File.cpp") ; 
    Write-Host $($Prefix + "Statue: Generate File: '$File/Preprocess.cpp'") ;
    $Command = "$Compiler -E -P $File.cpp -o $File/Preprocess.cpp"
    if ( Test-Path "$File/Compile/Options.txt") 
      {
        $Command += " " + $( Get-Content "$File/Compile/Options.txt" -Raw)
      }
    Write-Host $($Prefix + "Command: $Command") ;
    Invoke-Expression $Command ;
    Write-Host "" ; 
  }

# Use: "$File/Compile/Options.txt"
# Generate: "$File/Preprocess.cpp", "$File/Compile/Command.ps1"
if ( $Action -eq "build" -or $Action -eq "compile" -or $Action -eq "test" -or $Action -eq "test-flush" )
  {
    Write-Host "Action: Compile";
    Write-Host $($Prefix + "Time: $(Get-Date -Format $TimeFormat)") ;
    Write-Host $($Prefix + "File: $File.cpp") ;
    if ( Test-Path "$File/Preprocess.Hash" ) 
      {
        if (( $( Get-FileHash "$File/Preprocess.cpp" -Algorithm SHA256 ).Hash.ToString() -eq $( Get-Content "$File/Preprocess.Hash" -Raw) ) -and ( Test-Path "$File/$FileBasenameNoExtension.exe" ))
          {
            Write-Host $($Prefix + "State: file unchanged") ;
            $FileChanged = $False ;
          }
        else 
          {
            Write-Host $($Prefix + "State: file changed") ;
            $FileChanged = $True ;
          }
      }
    if ( -not (Test-Path "$File/$FileBasenameNoExtension.exe") )
      {
        Write-Host $($Prefix + "State: executable file does not exist") ;
        $FileChanged = $True ;
      }
    if ( $FileChanged ) 
      {
        # Remove Execute File
        if ( Test-Path "$File/$FileBasenameNoExtension.exe" )
          {
            Write-Host $($Prefix + "Statue: Remove File: '$File/$FileBasenameNoExtension.exe'") ; 
            Remove-Item "$File/$FileBasenameNoExtension.exe" ;
          }
        # Create file hash value
        Write-Host $($Prefix + "State: Create file hash") ;
        $( Get-FileHash "$File/Preprocess.cpp" -Algorithm SHA256 ).Hash | Out-File -FilePath "$File/Preprocess.Hash" -NoNewline ;
        # Build compile command
        $Command = "$Compiler $File.cpp -o $File/$FileBasenameNoExtension.exe" ;
        if ( Test-Path "$File/Compile/Options.txt") 
          {
            $Command += " " + $( Get-Content "$File/Compile/Options.txt" -Raw)
          }
        "# Create this file and run at $(Get-Date -Format $TimeFormat)" | Out-File -FilePath "$File/Compile/Command.ps1" ; 
        "$Command ;" | Out-File -FilePath "$File/Compile/Command.ps1" -Append -NoNewline ;
        Write-Host $($Prefix + "Command: $Command") ;
        Invoke-Expression $Command
        if ( Test-Path "$File/$FileBasenameNoExtension.exe") 
          {
            Write-Host $($Prefix + "State: compile successfully") ;
          }
        else
          {
            Write-Error "Error: compile failed" ;
            Exit 1 ;
          }
      }
    Write-Host "" ; 
  }

# Use: "$File/Execute/Argument.txt", "$File/Execute/Input.txt", "$File/Execute/Output.txt", "$File/Execute/OutputHistory.txt"
# Generate: "$File/Preprocess.cpp", "$File/Compile/Command.ps1"
if ( $Action -eq "test" -or $Action -eq "test-flush" )
  {
    Write-Host "Action: Execute";
    Write-Host $($Prefix + "Time: $(Get-Date -Format $TimeFormat)") ;
    Write-Host $($Prefix + "File: $File/$FileBasenameNoExtension.exe") ; 
    $Command = "$File/$FileBasenameNoExtension.exe" ;
    if ( Test-Path $Command )
      {
        if ( Test-Path "$File/Execute/Argument.txt" ) { $Command += " " + $( Get-Content "$File/Execute/Argument.txt" -Raw) }
        if ( Test-Path "$File/Execute/Input.txt" ) { $Command = "Get-Content $File/Execute/Input.txt -Raw" + " | " + $Command }
        if ( Test-Path "$File/Execute/Output.txt" ) { $Command += " > " + "$File/Execute/Output.txt" }
        "# Create this file and run at $(Get-Date -Format $TimeFormat)" | Out-File -FilePath "$File/Execute/Command.ps1" ; 
        "$Command ;" | Out-File -FilePath "$File/Execute/Command.ps1" -Append -NoNewline ;
        Write-Host $($Prefix + "Command: $Command") ; 
        Write-Host "" ; 
        Invoke-Expression $Command ;
        if ( Test-Path "$File/Execute/OutputHistory.txt" ) 
          { 
            "$ Run at $(Get-Date -Format $TimeFormat)" | Out-File -FilePath "$File/Execute/OutputHistory.txt" -Append ; 
            $( Get-Content "$File/Execute/Output.txt" -Raw) | Out-File -FilePath "$File/Execute/OutputHistory.txt" -Append ; 
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
  Write-Host $($Prefix + "Time: $(Get-Date -Format $TimeFormat)") ;
  Write-Host $($Prefix + "File: $File.cpp") ;
  if ( Test-Path "$File/$FileBasenameNoExtension.exe" )
    {
      Write-Host $($Prefix + "Statue: Remove File: '$File/$FileBasenameNoExtension.exe'") ; 
      Remove-Item "$File/$FileBasenameNoExtension.exe" ;
    }
  Write-Host "" ; 
}
