$script:project_config = "Release"

properties {

  Framework '4.5.1'

  $project_name = "RoundhousE.Psake.Example"
  $sub_project_name = "SimpleProject"

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
  $app_dir = "$source_dir\$project_name"
  $result_dir = "$build_dir\results"

  $nuget_exe = "$source_dir\.nuget\nuget.exe"

  $roundhouse_dir = "$base_dir\tools\roundhouse"
  $roundhouse_output_dir = "$roundhouse_dir\output"
  $roundhouse_exe_path = "$roundhouse_dir\rh.exe"
  $roundhouse_local_backup_folder = "$base_dir\database_backups"

  $packageId = if ($env:package_id) { $env:package_id } else { "$project_name" }

  $db_server = if ($env:db_server) { $env:db_server } else { ".\SqlExpress"  }
  $db_name = if ($env:db_name) { $env:db_name } else { "NORTHWND" }

  $dev_connection_string_name = "$project_name.ConnectionString"
  $devConnectionString = if(test-path env:$dev_connection_string_name) { (get-item env:$dev_connection_string_name).Value } else { "Server=$db_server;Database=$db_name;Trusted_Connection=True;MultipleActiveResultSets=true" }
  
  $db_scripts_dir = "$source_dir\DatabaseMigration"

}

#These are aliases for other build tasks. They typically are named after the camelcase letters (rd = Rebuild Databases)
#aliases should be all lowercase, conventionally
#please list all aliases in the help task
task default -depends Compile
task cl -depends Clean
task rb -depends Rebuild
task rad -depends RebuildDatabase
task ? -depends help

task help {
   Write-Help-Header
   Write-Help-Section-Header "Comprehensive Building"
   Write-Help-For-Alias "(default)" "Preforms a regular build"
   Write-Help-For-Alias "cl" "Preforms a clean build"
   Write-Help-For-Alias "rb" "Preforms a rebuild (clean and build)" 
   Write-Help-For-Alias "rad" "Builds/Rebuild Northwind database" 
   Write-Help-Footer
   exit 0
}

task Compile { 
	exec { & $nuget_exe restore $source_dir\$project_name.sln }
    exec { msbuild.exe /t:build /v:q /p:Configuration=$project_config /p:Platform="Any CPU" /nologo $source_dir\$project_name.sln }
}


task Clean {
    exec { msbuild /t:clean /v:q /p:Configuration=$project_config /p:Platform="Any CPU" $source_dir\$project_name.sln }
}

task Rebuild -depends Clean, Compile

task RebuildDatabase -depends Compile{
   deploy-database "Rebuild" $devConnectionString $db_scripts_dir "DEV"
}


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
function deploy-database($action, $connectionString, $scripts_dir, $env, $indexes) {
    $roundhouse_version_file = "$source_dir\$sub_project_name\bin\$sub_project_name.dll"

    write-host "roundhouse version file: $roundhouse_version_file"
    write-host "action: $action"
    write-host "connectionString: $connectionString"    
    write-host "scripts_dir: $scripts_dir"
    write-host "env: $env"

    if (!$env) {
        $env = "LOCAL"
        Write-Host "RoundhousE environment variable is not specified... defaulting to 'LOCAL'"
    } else {
        Write-Host "Executing RoundhousE for environment:" $env
    }  
   
    # Run roundhouse commands on $scripts_dir
    if ($action -eq "Update"){
       exec { &$roundhouse_exe_path -cs "$connectionString" --commandtimeout=300 -f $scripts_dir --env $env --silent -o $roundhouse_output_dir --transaction --amg afterMigration }
    }
    if ($action -eq "Rebuild"){
      $indexesFolder = if ($indexes -ne $null) { $indexes } else { "indexes" }
       exec { &$roundhouse_exe_path -cs "$connectionString" --commandtimeout=300 --env $env --silent -drop -o $roundhouse_output_dir }
       exec { &$roundhouse_exe_path -cs "$connectionString" --commandtimeout=300 -f $scripts_dir -env $env -vf $roundhouse_version_file --silent --simple -o $roundhouse_output_dir --transaction --amg afterMigration --indexes $indexesFolder }
    }
}