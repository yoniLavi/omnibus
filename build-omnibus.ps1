# can be called form SSH like so:
# powershell C:\omnibus\build-omnibus.ps1 'chef-full' 'opscode-full-stack' 'ACCESS_KEY' 'SECRET_KEY'

$project_name = $args[0]
$bucket_name = $args[1]
$s3_access_key = $args[2]
$s3_secret_key = $args[3]

Write-Output "Starting omnibus build of $project_name"

New-Item C:\chef-solo -type directory > $ENV:TEMP\omnibus.out 2>&1
$json_attribs = @"
{
  "aws": {
    "access_key": "$s3_access_key",
    "secret_access_key": "$s3_secret_key"
  },
  "$project_name": {
    "version": "0.10.4",
    "iteration": "1",
    "bucket_name": "$bucket_name"
  },
  "run_list": [
    "recipe[omnibus::default]"
  ]
}
"@

$json_attribs | Out-File -Encoding ASCII C:\chef-solo\omnibus.json

# (FU) MS - we have to use a script block since Write-Host output doesn't go to STDERR or STDOUT
# https://connect.microsoft.com/PowerShell/feedback/details/283088/script-logging-needs-to-be-improved
$script = {
  Start-Process -FilePath 'git' 'pull' -WorkingDirectory "C:\omnibus" -Wait -NoNewWindow
  Start-Process -FilePath 'chef-solo' '-c c:/chef-solo/solo.rb -j c:/chef-solo/omnibus.json' -Wait -NoNewWindow
}

PowerShell $script >> $ENV:TEMP\omnibus.out 2>&1

Write-Output "Finished build of $project_name"
