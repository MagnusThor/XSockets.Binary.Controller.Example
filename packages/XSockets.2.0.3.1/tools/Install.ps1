param($installPath, $toolsPath, $package, $project)

#install.ps1 v: 2.0
$defaultProject = Get-Project

if($defaultProject.Type -ne "C#"){
	Write-Host "Sorry, XSockets is only available for C#"
	return
}

$defaultNamespace = (Get-Project $defaultProject.Name).Properties.Item("DefaultNamespace").Value
$path = $defaultProject.FullName.Replace($defaultProject.Name + '.csproj','').Replace('\\','\')
$pluginPath = $path + "XSocketServerPlugins\"
$sln = [System.IO.Path]::GetFilename($dte.DTE.Solution.FullName)
$newProjPath = $dte.DTE.Solution.FullName.Replace($sln,'').Replace('\\','\')
$sln = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

###################################
#Adding plugin info to config     #
###################################
$webconfig = $path + "Web.config"
Write-Host "Getting content of $webconfig."
$xml = [xml](get-content($webconfig))

Write-Host "Adding appsettingsin $webconfig"

if($xml.configuration['appSettings'] -eq $null){
    Write-Host 'Add appsettings'
    $a = $xml.CreateElement('appSettings')
    $xml.configuration.AppendChild($a)
}

$pluginCatalog = $xml.CreateElement('add')
$pluginCatalog.setAttribute('key','XSockets.PluginCatalog')
$pluginCatalog.setAttribute('value','XSockets\XSocketServerPlugins\')
$xml.configuration["appSettings"].AppendChild($pluginCatalog)

$pluginFilter = $xml.CreateElement('add')
$pluginFilter.setAttribute('key','XSockets.PluginFilter')
$pluginFilter.setAttribute('value','*.dll')
$xml.configuration["appSettings"].AppendChild($pluginFilter)

Write-Host "Saving $webconfig."
$xml.Save($webconfig)

###################################
#Add DevelopmentServer project	  #
###################################
if(($DTE.Solution.Projects | Select-Object -ExpandProperty Name) -notcontains 'XSockets.DevServer'){
Write-Host "Adding XSockets.DevServer project"
$templatePath = $sln.GetProjectTemplate("ClassLibrary.zip","CSharp")
$sln.AddFromTemplate($templatePath, $newProjPath+"XSockets.DevServer","XSockets.DevServer")
$file = Get-ProjectItem "Class1.cs" -Project XSockets.DevServer
$file.Remove()
}
# Get the current Pre Build Event cmd
(Get-Project XSockets.DevServer).ConfigurationManager.ActiveConfiguration.Properties.Item("OutputPath").Value = "bin\Debug"

Write-Host (Get-Project XSockets.DevServer).Name Installing : XSockets.Core -ForegroundColor DarkGreen
Install-Package XSockets.Core -ProjectName (Get-Project XSockets.DevServer).Name

Scaffold DevelopmentDebugServer

###################################
#End of Add DevelopmentServer     #
###################################

#Add ref to DevServer in WebProject
(Get-Project $defaultProject.Name).Object.References.AddProject((Get-Project XSockets.DevServer))

###################################
#Add XSocketHandler project	      #
###################################
if(($DTE.Solution.Projects | Select-Object -ExpandProperty Name) -notcontains 'XSocketHandler'){
Write-Host "Adding XSocketHandler project"
$templatePath = $sln.GetProjectTemplate("ClassLibrary.zip","CSharp")
$sln.AddFromTemplate($templatePath, $newProjPath+"XSocketHandler","XSocketHandler")
$file = Get-ProjectItem "Class1.cs" -Project XSocketHandler
$file.Remove()
}
# Get the current Pre Build Event cmd
(Get-Project XSocketHandler).ConfigurationManager.ActiveConfiguration.Properties.Item("OutputPath").Value = "bin\Debug"

Write-Host (Get-Project XSocketHandler).Name Installing : XSockets.Core -ForegroundColor DarkGreen
Install-Package XSockets.Core -ProjectName (Get-Project XSocketHandler).Name

###################################
#End of Add XSocketHandler        #
###################################

###################################
#Setup post and pre build events  #
#for XSocketHandler               #
###################################

# Get the current Post Build Event cmd
$currentPostBuildCmd = (Get-Project XSocketHandler).Properties.Item("PostBuildEvent").Value

$postBuildAddCmd = "copy `"`$(TargetPath)`", `"`$(SolutionDir)"+$defaultProject.Name+"\XSockets\XSocketServerPlugins\`""

# Append our post build command if it's not already there
if (!$currentPostBuildCmd.Contains($postBuildAddCmd)) {
    (Get-Project XSocketHandler).Properties.Item("PostBuildEvent").Value += $postBuildAddCmd
}

# Get the current Pre Build Event cmd
$currentPreBuildCmd = (Get-Project XSocketHandler).Properties.Item("PreBuildEvent").Value

$preBuildAddCmd = "IF NOT EXIST `"`$(SolutionDir)"+$defaultProject.Name+"\XSockets\XSocketServerPlugins\`" mkdir `"`$(SolutionDir)"+$defaultProject.Name+"\XSockets\XSocketServerPlugins\`""

# Append our pre build command if it's not already there
if (!$currentPreBuildCmd.Contains($preBuildAddCmd)) {
    (Get-Project XSocketHandler).Properties.Item("PreBuildEvent").Value += $preBuildAddCmd
}

###################################
#End Setup post/pre build events  #
###################################

###################################
#Setup post and pre build events  #
#for DevelopmentServer            #
###################################

# Get the current Post Build Event cmd
$currentPostBuildCmd = (Get-Project XSockets.DevServer).Properties.Item("PostBuildEvent").Value

$postBuildAddCmd = "copy `"`$(TargetPath)`", `"`$(SolutionDir)"+$defaultProject.Name+"\XSockets\XSocketServerPlugins\`""

# Append our post build command if it's not already there
if (!$currentPostBuildCmd.Contains($postBuildAddCmd)) {
    (Get-Project XSockets.DevServer).Properties.Item("PostBuildEvent").Value += $postBuildAddCmd
}

# Get the current Pre Build Event cmd
$currentPreBuildCmd = (Get-Project XSockets.DevServer).Properties.Item("PreBuildEvent").Value

$preBuildAddCmd = "IF NOT EXIST `"`$(SolutionDir)"+$defaultProject.Name+"\XSockets\XSocketServerPlugins\`" mkdir `"`$(SolutionDir)"+$defaultProject.Name+"\XSockets\XSocketServerPlugins\`""

# Append our pre build command if it's not already there
if (!$currentPreBuildCmd.Contains($preBuildAddCmd)) {
    (Get-Project XSockets.DevServer).Properties.Item("PreBuildEvent").Value += $preBuildAddCmd
}

###################################
#End Setup post/pre build events  #
###################################



###################################
#Add fallback if MVC
###################################
if(((Get-Project $defaultProject.Name).Object.References | Where-Object {$_.Name -eq "System.Web.Mvc"}) -ne $null){ 
    ###################################
    #Start new debugserver on appstart#
    ###################################
    Add-CodeToMethod $defaultProject.Name "\" "Global.asax.cs" "MvcApplication" "Application_Start" "new XSockets.DevServer.DebugInstance();"

    Write-Host $defaultProject.Name Installing : XSockets.Fallback -ForegroundColor DarkGreen
    Install-Package XSockets.Fallback -ProjectName $defaultProject.Name
    ###################################
    #Add Fallback controller          #
    ###################################
    Add-CodeToMethod $defaultProject.Name '\' 'Global.asax.cs' 'MvcApplication' 'RegisterRoutes' 'routes.MapRoute("Fallback","{controller}/{action}",new {controller = "Fallback", action = "Init"},new[] {"XSockets.Longpolling"});'
}
else{
    #WEBFORMS
    ###################################
    #Start new debugserver on appstart#
    ###################################
    Add-CodeToMethod $defaultProject.Name "\" "Global.asax.cs" "Global" "Application_Start" "new XSockets.DevServer.DebugInstance();"
}