#variables
$break = ""

#Get name of Remote PC with installed apps
$pcName = Read-Host -Prompt "Enter Name of Remote PC: "

#Get List of Applications installed on Remote PC
$appList = Get-WmiObject Win32_Product -ComputerName $pcName | Select-Object Name,Version

#Get List of Applications installed on Local PC
$localAppList = Get-WmiObject Win32_Product | Select-Object Name,Version

#Create Folder
$ErrorActionPreference = "Stop"
try {
    New-Item -Path "C:\" -Name "PCR Tool Logs" -ItemType "directory"
    $break
    $break
}
catch  
{
    Write-Output "Processing..."
    $break
}

#Create CSV of Apps installed on Remote PC 
$appList | Export-CSV -Path "C:\PCR Tool Logs\VersionList.csv"

#Create CSV of Apps installed on Local PC
$localAppList | Export-CSV -Path "C:\PCR Tool Logs\localAppList.csv"

#Create Compare Objects
$file1 = Import-Csv -Path "C:\PCR Tool Logs\VersionList.csv"
$file2 = Import-Csv -Path "C:\PCR Tool Logs\localAppList.csv"

#Compare CSVs against each other
Compare-Object -ReferenceObject $file1 -DifferenceObject $file2 -Property Name -IncludeEqual | Export-CSV -Path "C:\PCR Tool Logs\AppComparison.csv"

#Create sorted CSV for Apps that are missing from Local PC
$csv = Import-CSV "C:\PCR Tool Logs\AppComparison.csv" 
$csv | Where-Object { $_.SideIndicator -eq '<=' } | export-csv "C:\PCR Tool Logs\NeededApps.csv" -NoTypeInformation

#Show CSV with the sorted items
Invoke-Item "C:\PCR Tool Logs\NeededApps.csv"