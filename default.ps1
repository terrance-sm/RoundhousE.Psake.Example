$script:project_config = "Release"

properties {

  Framework '4.5.1'

  $project_name = "RoundhousE.Psake.Example"

  if(-not $version)
  {
      $version = "0.0.0.1"
  }

  $date = Get-Date  

  $ReleaseNumber =  $version
  
  Write-Host "**********************************************************************"
  Write-Host "Release Number: $ReleaseNumber"
  Write-Host "**********************************************************************"
  

  $base_dir = resolve-path .
  $build_dir = "$base_dir\build"     
  $source_dir = "$base_dir\src"
  $app_dir = "$source_dir\$project_name"  #
  $result_dir = "$build_dir\results"

  $packageId = if ($env:package_id) { $env:package_id } else { "$project_name" }
}

#These are aliases for other build tasks. They typically are named after the camelcase letters (rd = Rebuild Databases)
#aliases should be all lowercase, conventionally
#please list all aliases in the help task
task default -depends Compile
task cl -depends Clean
task rb -depends Rebuild
task ? -depends help

task help {
   Write-Help-Header
   Write-Help-Section-Header "Comprehensive Building"
   Write-Help-For-Alias "(default)" "Preforms a regular build"
   Write-Help-For-Alias "cl" "Preforms a clean build"
   Write-Help-For-Alias "rb" "Preforms a rebuild (clean and build)" 
   Write-Help-Footer
   exit 0
}

task Compile { 
    exec { msbuild.exe /t:build /v:q /p:Configuration=$project_config /p:Platform="Any CPU" /nologo $source_dir\$project_name.sln }
}


task Clean {
    exec { msbuild /t:clean /v:q /p:Configuration=$project_config /p:Platform="Any CPU" $source_dir\$project_name.sln }
}

task Rebuild -depends Clean, Compile


# -------------------------------------------------------------------------------------------------------------
# generalized functions added by Headspring for Help Section
# --------------------------------------------------------------------------------------------------------------

function Write-Help-Header($description) {
   Write-Host ""
   Write-Host "********************************" -foregroundcolor DarkGreen -nonewline;
   Write-Host " HELP " -foregroundcolor Green  -nonewline; 
   Write-Host "********************************"  -foregroundcolor DarkGreen
   Write-Host ""
   Write-Host "This build script has the following common build " -nonewline;
   Write-Host "task " -foregroundcolor Green -nonewline;
   Write-Host "aliases set up:"
}

function Write-Help-Footer($description) {
   Write-Host ""
   Write-Host " For a complete list of build tasks, view default.ps1."
   Write-Host ""
   Write-Host "**********************************************************************" -foregroundcolor DarkGreen
}

function Write-Help-Section-Header($description) {
   Write-Host ""
   Write-Host " $description" -foregroundcolor DarkGreen
}

function Write-Help-For-Alias($alias,$description) {
   Write-Host "  > " -nonewline;
   Write-Host "$alias" -foregroundcolor Green -nonewline; 
   Write-Host " = " -nonewline; 
   Write-Host "$description"
}

# -------------------------------------------------------------------------------------------------------------
# generalized functions 
# --------------------------------------------------------------------------------------------------------------
#function global:delete_file($file) {
#    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
#}