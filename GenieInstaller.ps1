#Github Release URL Info
$releaseDownloadURL = "https://github.com/GenieClient/Genie4/releases/download/4.0.2.0/"
$releaseDownloadURL -match 'https://github.com/(?<GithubUser>.*)/(?<GithubRepo>.*)/releases/download/(?<Version>.*)/'

#Git Repo Stuff
$gitHubUser = $Matches.GithubUser
$gitHubRepo = $Matches.GithubRepo
$gitHubVersion = $Matches.Version
$genieGitURL = "https://github.com/$gitHubUser/$gitHubRepo/releases/download/$gitHubVersion/"

#Where to create the genie folder at?
$genieInstallRootFolder = "C:\temp\"

#Formatting of Genie FolderName (Genie Client <version without periods>. Ex. Genie Client 4020).
$genieVersionName = $gitHubVersion.Replace(".", "")
$genieFolderName = "Genie-$genieVersionName"

#Name of files in Repo, package specific stuff will be generated using a switch below
$genieConfigFiles = "Base.Config.Files.zip"
$geniePlugins = "Plugins.zip"

#Parent Installation Path, change $genieInstallRootFolder
$fullGenieFolderPath = "$genieInstallRootFolder$genieFolderName\"

#function to provide an exit
function PromptYesNo {
    while ("yes","no" -notcontains $yorn_answer)
    {
        $yorn_answer = Read-Host "Continue? (Yes/No)"
    }
        if ($yorn_answer -eq "no"){
            Write-Host "Exiting..." -ForegroundColor Red
        exit
        }
}

#start of script
Clear-Host

Write-Host "-----------------------------------------------------"  -ForegroundColor Green
Write-Host "Seks EZ Genie4 Installer"                               -ForegroundColor Green
Write-Host "-----------------------------------------------------"  -ForegroundColor Green
Write-Host "GITHUB URL: $genieGitURL"
Write-Host ""                                                       -ForegroundColor Green
Write-Host "Available Builds:"                                      -ForegroundColor Yellow
Write-Host "- Option 1: x86"                                        -ForegroundColor Yellow
Write-Host "- Option 2: x64"                                        -ForegroundColor Yellow
Write-Host "- Option 3: x64 Runtime Dependent"                      -ForegroundColor Yellow
Write-Host "- Option 4: Cancel"                                     -ForegroundColor Yellow
Write-Host "" 

#switch to select certain package
$buildanswer = Read-Host "Please make a numeric selection from options above (1,2,3,4)"
switch ($buildanswer) {
    1 {$geniePackage = "Genie4-x86.zip"}
    2 {$geniePackage = "Genie4-x64.zip"}
    3 {$geniePackage = "Genie4-x64-Runtime-Dependent.zip"}
    4 {
        write-host "Exiting..."                                     -ForegroundColor Red
        exit
    }
    default{
        write-host "No Match Found..."
        exit
    }
}

Write-Host "-----------------------------------------------------"  -ForegroundColor Green
Write-Host ""
Write-Host "GITHUB URL:             $genieGitURL"                   -ForegroundColor Yellow
Write-Host "Config Package:         $genieConfigFiles"              -ForegroundColor Yellow
write-Host "Plugins:                $geniePlugins"                  -ForegroundColor Yellow
Write-Host "Application Package:    $geniePackage"                  -ForegroundColor Yellow
Write-Host ""
Write-Host "Install Path:           $fullGenieFolderPath"           -ForegroundColor Yellow
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green

#verification of some config
Write-Host ""
PromptYesNo
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green  
#makes the new folder
Write-Host ""
Write-Host "Making new directory:   $fullGenieFolderPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green
PromptYesNo
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green
#if folder exists, see if its empty.. if not exit. If folder exists but is empty, continue. If older is new make it!
if (Test-Path $fullGenieFolderPath) {
    Write-Host ""
    Write-Host "Folder already exists..." -ForegroundColor Yellow
    Write-Host ""
    $folderfilecount = (Get-ChildItem -Path $fullGenieFolderPath -File | Measure-Object).Count
    if ($folderfilecount -gt 0){
        Write-Host "  -Folder is not empty. please remove/clean out this folder and rerun this script." -ForegroundColor Yellow
        Exit
    }
}
else
{
    New-Item $fullGenieFolderPath -ItemType Directory
    Write-Host ""
    Write-Host "Folder Created successfully..." -ForegroundColor Green
}
#Downloads files via Invoke-WebRequest
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green  
Write-Host ""
Write-Host "Downloading files via Invoke-WebRequest..."             -ForegroundColor Yellow
Write-Host ""
Write-Host "GITHUB URL:             $genieGitURL"                   -ForegroundColor Yellow
Write-Host "Config Package:         $genieConfigFiles"              -ForegroundColor Yellow
write-Host "Plugins:                $geniePlugins"                  -ForegroundColor Yellow
Write-Host "Application Package:    $geniePackage"                  -ForegroundColor Yellow
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green  
Write-Host ""
PromptYesNo
Write-Host ""
Invoke-WebRequest -Uri "$genieGitURL$genieConfigFiles" -OutFile "$fullGenieFolderPath$genieConfigFiles"
Invoke-WebRequest -Uri "$genieGitURL$geniePlugins" -OutFile "$fullGenieFolderPath$geniePlugins"
Invoke-WebRequest -Uri "$genieGitURL$geniePackage" -OutFile "$fullGenieFolderPath$geniePackage"
#extracts the stuff in order
Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
Write-Host "" 
Write-Host "Extract the ZIP files into:   $fullGenieFolderPath ?"   -ForegroundColor Yellow
Write-Host "" 
Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
PromptYesNo
Expand-Archive -LiteralPath "$fullGenieFolderPath$genieConfigFiles" -DestinationPath "$fullGenieFolderPath" -ErrorAction SilentlyContinue
Expand-Archive -LiteralPath "$fullGenieFolderPath$geniePlugins" -DestinationPath "$fullGenieFolderPath" -ErrorAction SilentlyContinue
Expand-Archive -LiteralPath "$fullGenieFolderPath$geniePackage" -DestinationPath "$fullGenieFolderPath" -ErrorAction SilentlyContinue
if (Test-Path $fullGenieFolderPath) {
    $folderfilecount = (Get-ChildItem -Path $fullGenieFolderPath -File | Measure-Object).Count
    if ($folderfilecount -gt 3){
        Write-Host "Extraction of files was completed..." -ForegroundColor Green
    }
    if ($folderfilecount -eq 3){
        Write-Host "Unable to extract the files properly..." -ForegroundColor Red
        exit
    }
}
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
#deletes the files
Write-Host ""
Write-Host "Cleaning Up Files downloaded to:   $fullGenieFolderPath"   -ForegroundColor Yellow
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green
Write-Host ""
PromptYesNo
remove-item $fullGenieFolderPath$genieConfigFiles -Force
remove-item $fullGenieFolderPath$geniePlugins -Force
remove-item $fullGenieFolderPath$geniePackage -Force
Write-Host ""
Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
Write-Host ""
Write-Host "END of Script, please verify that Genie.exe launches successfully!" -ForegroundColor Green 
Write-Host "Enjoy" -ForegroundColor Green 
exit