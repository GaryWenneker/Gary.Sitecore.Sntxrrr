  [cmdletBinding()]
    
    param
    (
        # Target nodes to apply the configuration
        [string[]]$DestinationPath,
        [string[]]$SourcePath
    )


configuration CopySitecoreFolder
{
    param
    (
        # Target nodes to apply the configuration
        [string[]]$DestinationPath,
        [string[]]$SourcePath
    )

	Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node 'localhost'
    {

        File SitecoreBase
        {
            Type = 'Directory'
			SourcePath = "$SourcePath"
            DestinationPath = "$DestinationPath"
            Ensure = "Present"
            Recurse = $true
        }
    }
}

CopySitecoreFolder -DestinationPath $DestinationPath -SourcePath $SourcePath
Start-DscConfiguration -Path .\CopySitecoreFolder -Wait -Force -Verbose