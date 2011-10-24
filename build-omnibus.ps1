# can be called form SSH like so:
# powershell C:\omnibus\build-omnibus.ps1 'chef-client' 'opscode-full-stack' 'ACCESS_KEY' 'SECRET_KEY'

# legacy chef-full name should be chef-client
if ($args[0] -eq "chef-full") {
  $project_name = "chef-client"
} else {
  $project_name = $args[0]
}
$bucket_name = $args[1]
$s3_access_key = $args[2]
$s3_secret_key = $args[3]
$current_dir = (Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path) -replace "\\$", ""

Write-Output "Starting omnibus build of $project_name"

$json_attribs = @"
{
  "aws": {
    "access_key": "$s3_access_key",
    "secret_access_key": "$s3_secret_key"
  },
  "omnibus": {
    "$project_name": {
      "version": "0.10.4",
      "iteration": "6",
      "bucket_name": "$bucket_name"
    }
  },
  "run_list": [
    "recipe[omnibus::default]"
  ]
}
"@

$json_attribs | Out-File -Encoding ASCII $current_dir\chef-repo\.chef\omnibus.json

# (FU) MS - we have to use a script block since Write-Host output doesn't go to STDERR or STDOUT
# https://connect.microsoft.com/PowerShell/feedback/details/283088/script-logging-needs-to-be-improved
$script = {
  Start-Process -FilePath 'git' 'pull' -WorkingDirectory "C:\omnibus" -Wait -NoNewWindow
  Start-Process -FilePath 'chef-solo' -c "$current_dir\chef-repo\.chef\solo.rb -j $current_dir\chef-repo\.chef\omnibus.json" -Wait -NoNewWindow
}

PowerShell $script >> $ENV:TEMP\omnibus.out 2>&1

Write-Output "Finished build of $project_name"