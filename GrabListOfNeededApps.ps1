#variables
$breakLine = ""

#Get name of Remote PC with installed apps
$pcName = Read-Host -Prompt "Enter Name of Remote PC: "
$breakLine

Write-Host "Please wait while the connection is being tested."
$breakLine

#Test connection to Remote PC
try {
    $test = Test-Connection -ComputerName $pcName
    #Get List of Applications installed on Remote PC
    $appList = Get-WmiObject Win32_Product -ComputerName $pcName | Select-Object Name,Version
}
catch {
    Write-Host "The Remote PC can't be reached. Make sure that the PC is connected to the Network."
    Start-Sleep -Seconds 10
    break
}

if ($test) {
    Write-Host "Connection to the remote PC is successful."
    $breakLine
    Write-Host "Generating list of needed apps...."
    $breakLine
    Start-Sleep -Seconds 5
}

#Get List of Applications installed on Remote PC
$appList = Get-WmiObject Win32_Product -ComputerName $pcName | Select-Object Name,Version

#Get List of Applications installed on Local PC
$localAppList = Get-WmiObject Win32_Product | Select-Object Name,Version

#Create Folder
$ErrorActionPreference = "Stop"
try {
    New-Item -Path "C:\" -Name "PCR Tool Logs" -ItemType "directory"
    $breakLine
    $breakLine
}
catch  
{
    Write-Output "Log directory has already been created. Skipping step."
    $breakLine
    $breakLine
}

#Create CSV of Apps installed on Remote PC 
$appList | Export-CSV -Path "C:\PCR Tool Logs\VersionList.csv"

#Create CSV of Apps installed on Local PC
$localAppList | Export-CSV -Path "C:\PCR Tool Logs\LocalAppList.csv"

#Create Compare Objects
$file1 = Import-Csv -Path "C:\PCR Tool Logs\VersionList.csv"
$file2 = Import-Csv -Path "C:\PCR Tool Logs\LocalAppList.csv"

#Compare CSVs against each other
Compare-Object -ReferenceObject $file1 -DifferenceObject $file2 -Property Name, Version -IncludeEqual | Export-CSV -Path "C:\PCR Tool Logs\AppComparison.csv"

#Create sorted CSV for Apps that are missing from Local PC
$csv = Import-CSV "C:\PCR Tool Logs\AppComparison.csv" 
$csv | Where-Object { $_.SideIndicator -eq '<=' } | export-csv "C:\PCR Tool Logs\NeededApps.csv" -NoTypeInformation

#Show CSV with the sorted items
Invoke-Item "C:\PCR Tool Logs\NeededApps.csv"