 [cmdletBinding()]
    
    param
    (
        # Target nodes to apply the configuration
        [string[]]$DeletePath
    )


function Remove-Tree($Path)
{ 
    Remove-Item $Path -Force -Recurse -ErrorAction silentlycontinue

    if (Test-Path "$Path\" -ErrorAction silentlycontinue)
    {
        $folders = Get-ChildItem -Path $Path –Directory -Force
        ForEach ($folder in $folders)
        {
            Remove-Tree $folder.FullName
        }

        $files = Get-ChildItem -Path $Path -File -Force

        ForEach ($file in $files)
        {
            Remove-Item $file.FullName -force
        }

        if (Test-Path "$Path\" -ErrorAction silentlycontinue)
        {
            Remove-Item $Path -force
        }
    }
}

Remove-Tree $DeletePath