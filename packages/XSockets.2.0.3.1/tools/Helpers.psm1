function Get-Domain($basetype){

	$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	
	$classes = $namespaces | ForEach{$_.Children}
	$ret = @()
	$classes | ForEach{
		$current = $_
		$_.Bases | ForEach{
			if($_.Name -eq $basetype){				
				$ret += $current
			}
		}		
	}	
	return $ret
}

function Get-SolutionPath(){
	$sln = [System.IO.Path]::GetFilename($dte.DTE.Solution.FullName)
	$path = $dte.DTE.Solution.FullName.Replace($sln,'').Replace('\\','\')	
	return $path
}

function Get-SolutionFile([string]$ProjectName, [string]$Folder = "", [string]$FileName){
	$path = Get-SolutionPath	
	return $path.Trim() + $ProjectName.Trim() + $Folder.Trim() + $FileName.Trim()	
}

function Add-CodeToMethod([string]$ProjectName, [string]$Folder = "", [string]$FileName,[string]$ClassName, [string]$MethodName, [string]$Code){
	$filepath = Get-SolutionFile $ProjectName $Folder $FileName	
	$file = $DTE.Solution.FindProjectItem($filepath)
	if($file -eq $null){
		return
	}
	$file.Open().Activate()
		
	$ns = $DTE.ActiveDocument.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}
	$classes = $ns | ForEach{$_.Children}	
	$classes | ForEach{	
		if(!($_.Name -eq $null)){						
			if($_.Name -eq $ClassName){
				$_.Children | ForEach{
					if($_.Name -eq $MethodName){	
						$addCode = $true
						$edit = $_.EndPoint.CreateEditPoint()
						$edit.GetLines($_.StartPoint.Line,$_.EndPoint.Line).split("`n") | ForEach{													
							if($_.Contains($Code)){								
								$addCode = $false
							}
						}												
						if($addCode -eq $true){
							$edit.StartOfLine()																	
							$edit.Insert($Code)
						}
					}					
				}	
			}
		}
	}	
	$DTE.ExecuteCommand("Edit.FormatDocument")
	$file.Save()	
	#$file.Close()
}


function Add-Namespace([string]$ProjectName, [string]$Folder = "", [string]$FileName,[string]$Namespace){
	$filepath = Get-SolutionFile $ProjectName $Folder $FileName
	
	$file = $DTE.Solution.FindProjectItem($filepath)
	$file.Open().Document.Activate()
	
	$checkForThis = "using $($Namespace);" 
	$exists = $false
	
	Get-Content $filepath | foreach-Object {  if($_.Contains($checkForThis)){ $exists = $true }}
	
	if($exists -eq $false){
		$DTE.ActiveDocument.Selection.StartOfDocument()
		$DTE.ActiveDocument.Selection.NewLine()
		$DTE.ActiveDocument.Selection.LineUp()
		$DTE.ActiveDocument.Selection.Insert($checkForThis)
		$DTE.ExecuteCommand("Edit.FormatDocument")
		$file.Save()	
		#$file.Close()
	}	
}

function Get-Class($classname){

	$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	#Write-Host $classname
	$classes = $namespaces | ForEach{$_.Children}
	$ret = $null
	#Write-Host $classes
	$classes | ForEach{	
		if(!($_.Name -eq $null)){						
			if($_.Name.Trim() -eq $classname){					
				$ret = $_
			}
		}
	}		
	#Write-Host $ret
	return $ret
}

function Get-Properties($type){
	if($type -eq $null){
		Write-Host "You have to provide a DTE class. Use Get-Domain 'BaseClass' or Get-Class 'classname' to get the class(es) you want"
		return $null
	}
	return ForEach{$type.Children | Where-Object{$_.Kind -eq 4}}
}

function Get-LineOfMethod([string]$type, [string]$methodName){	
	
	$t = Get-Class($type)
	$ret = $null
	$t.Children | ForEach{
		if($_.Name -eq $methodName){
			Write-Host "Method found"
			Write-Host $_
			$ret = $_.EndPoint.Line
		}
	}
	
	return $ret	
}

function Add-Text([string]$type = "", [string]$methodName, [string]$text){	
	
	$m = Get-LineOfMethod($type,$methodName)
	Write-Host $m
	return $m	
}

Register-TabExpansion 'Get-Properties' @{"type"=$null}
Register-TabExpansion 'Get-Domain' @{
	'basetype' = {
					"PersistentEntity",
					"Object"
				 }
}

Export-ModuleMember Get-Domain
Export-ModuleMember Get-Class
Export-ModuleMember Get-LineOfMethod
Export-ModuleMember Get-Properties
Export-ModuleMember Get-SolutionPath
Export-ModuleMember Add-CodeToMethod
Export-ModuleMember Add-Namespace

#Import-Module "C:\Dropbox\CodePlanner\Nuget\CodePlanner.0.2\CodePlannerTools.psm1"