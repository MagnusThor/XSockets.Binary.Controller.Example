[T4Scaffolding.Scaffolder(Description = "Scaffold the debug server code")][CmdletBinding()]
param(        
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

$ProjectName = 'XSockets.DevServer'
$outputPath = "DebugInstance"

Add-ProjectItemViaTemplate $outputPath -Template DevelopmentDebugServerTemplate `
    -Model @{} `
	-SuccessMessage "Added DevelopmentDebugServer output at {0}" `
	-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force

$outputPath = "CustomConfigurationLoader"
Add-ProjectItemViaTemplate $outputPath -Template CustomConfigurationLoaderTemplate `
    -Model @{} `
	-SuccessMessage "Added CustomConfigurationLoader output at {0}" `
	-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force