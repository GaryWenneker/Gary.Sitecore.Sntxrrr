param([string]$url, [string]$secret, [string[]]$configurations)
$ErrorActionPreference = 'Stop'

# This is an example PowerShell script that will remotely execute a Unicorn sync using the new CHAP authentication system.

Import-Module .\Unicorn.psm1

Sync-Unicorn -ControlPanelUrl $url -SharedSecret $secret -Configurations $configurations

# Note: you may pass -Verb 'Reserialize' for remote reserialize. Usually not needed though.
#Foundation.Core,Foundation.Master.Root,Foundation.Master,Framework.Core,Framework.Master,Macaw.Framework.Security,Project.PiCompany.Website,Project.PiCompany.Metadata,Project.PiCompany.Website.Security,Project.PiCompany.CentralRepository