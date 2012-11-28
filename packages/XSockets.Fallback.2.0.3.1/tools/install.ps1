param($installPath, $toolsPath, $package, $project)
#install.ps1 v: 2.0
$defaultProject = Get-Project

if($defaultProject.Type -ne "C#"){
	Write-Host "Sorry, XSockets is only available for C#"
	return
}
if(($defaultProject.Object.References | Where-Object {$_.Name -eq "System.Web.Mvc"}) -eq $null){  
    Write-Host 'Sorry, Can only install XSockets.Fallback in ASP.NET MVC projects' -ForegroundColor DarkRed   
    return
}