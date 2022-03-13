#   By Sekmeht Usho - 13MAR2021
#   https://github.com/SekmehtDR/DRstuff

#Github Release URL Info - Important to update the numeric value in the download URL below
$releaseDownloadURL = "https://github.com/GenieClient/Genie4/releases/download/4.0.2.1/"
$releaseDownloadURL -match 'https://github.com/(?<GithubUser>.*)/(?<GithubRepo>.*)/releases/download/(?<Version>.*)/'

#Git Repo Stuff
$gitHubUser = $Matches.GithubUser
$gitHubRepo = $Matches.GithubRepo
$gitHubVersion = $Matches.Version
$genieGitURL = "https://github.com/$gitHubUser/$gitHubRepo/releases/download/$gitHubVersion/"

#Where to create the genie folder at (Default)?
$genieInstallRootFolder = "C:\temp\"

#Where to migrate Genie folder from? (Default)
$genieMigrateRootFolder = "C:\temp\Genie-XXXX"

#Formatting of Genie FolderName (Genie Client <version without periods>. Ex. Genie Client 4020).
$genieVersionName = $gitHubVersion.Replace(".", "")
$genieFolderName = "Genie-$genieVersionName"

#Name of files in Repo, package specific stuff will be generated using a switch below
$genieConfigFiles = "Base.Config.Files.zip"
$geniePlugins = "Plugins.zip"

#Parent Installation Path, change $genieInstallRootFolder
$fullGenieFolderPath = "$genieInstallRootFolder$genieFolderName\"

#Microsoft Desktop Runtime Stuff
$windowsdesktopruntimeSource = "https://download.visualstudio.microsoft.com/download/pr/7f3a766e-9516-4579-aaf2-2b150caa465c/d57665f880cdcce816b278a944092965/windowsdesktop-runtime-6.0.3-win-x64.exe"
$windowsdesktopruntimeFilename = "windowsdesktop-runtime-6.0.3-win-x64.exe"

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

#START OF SCRIPT, MAIN MENU SELECTION
Clear-Host
Write-Host "-----------------------------------------------------"  -ForegroundColor Green
Write-Host "Genie 4 Deployment Tool"                                -ForegroundColor Green
Write-Host "-----------------------------------------------------"  -ForegroundColor Green
Write-Host ""                                                       -ForegroundColor Green
Write-Host "Available Options:"                                     -ForegroundColor Yellow
Write-Host "- Option 1: Install - NEW - Genie $gitHubVersion"       -ForegroundColor Yellow
Write-Host "- Option 2: Upgrade - EXISTING - Genie 4.X.X.X"         -ForegroundColor Yellow
Write-Host "- Option 3: Migrate - Upgrade - Genie 3.X.X.X "         -ForegroundColor Yellow
Write-Host "- Option 4: Cancel"                                     -ForegroundColor Yellow
Write-Host "" 
$deploymentOption = Read-Host "Please make a numeric selection from the options above"
switch ($deploymentOption) {
    1 {$deploymentOption = "Install"}
    2 {$deploymentOption = "Upgrade"}
    3 {$deploymentOption = "Migrate"}
    4 {
        write-host "Canceling..."                                     -ForegroundColor Red
        exit
    }
    default{
        write-host "No Match Found..."
        exit
    }
}
### Option 1: Install Start ###
Write-Host "$deploymentOption"

if ($deploymentOption -eq "Install"){
    Clear-Host
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host "Option 1: Install - NEW - Genie $gitHubVersion"
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host "GITHUB URL: $genieGitURL"
    Write-Host ""                                                       -ForegroundColor Green
    Write-Host "Available Builds:"                                      -ForegroundColor Yellow
    Write-Host "- Option 1: x86"                                        -ForegroundColor Yellow
    Write-Host "- Option 2: x64"                                        -ForegroundColor Yellow
    Write-Host "- Option 3: x64 Runtime Dependent"                      -ForegroundColor Yellow
    Write-Host "- Option 4: Cancel"                                     -ForegroundColor Yellow
    Write-Host "" 

    #Switch VAR String to select certain package
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

    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host ""
    Write-Host "GITHUB URL:             $genieGitURL"                   -ForegroundColor Yellow
    Write-Host "Config Package:         $genieConfigFiles"              -ForegroundColor Yellow
    write-Host "Plugins:                $geniePlugins"                  -ForegroundColor Yellow
    Write-Host "Application Package:    $geniePackage"                  -ForegroundColor Yellow
    if ($buildanswer -eq "3") {
        Write-Host "Desktop Runtime:        $windowsdesktopruntimeFilename" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Install Path:           $fullGenieFolderPath"           -ForegroundColor Yellow
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green

    #verification of some config
    PromptYesNo
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green  
    #makes the new folder
    Write-Host ""
    Write-Host "Making new directory:   $fullGenieFolderPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    PromptYesNo
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    #if folder exists, see if its empty.. if not exit. If folder exists but is empty, continue. If older is new make it!
    if (Test-Path $fullGenieFolderPath) {
        Write-Host ""
        Write-Host "Folder already exists..." -ForegroundColor Yellow
        $folderfilecount = (Get-ChildItem -Path $fullGenieFolderPath -File | Measure-Object).Count
        if ($folderfilecount -gt 0){
            Write-Host "  -Folder is not empty. please remove/clean out this folder and rerun this script." -ForegroundColor Yellow
            Write-Host ""
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
    if ($buildanswer -eq "3") {
        Write-Host "Desktop Runtime:        $windowsdesktopruntimeFilename" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green  
    PromptYesNo
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green  
    Write-Host ""
    Write-Host "Downloading $genieConfigFiles to $fullGenieFolderPath"   -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$genieGitURL$genieConfigFiles" -OutFile "$fullGenieFolderPath$genieConfigFiles"
    Write-Host "Downloading $geniePlugins to $fullGenieFolderPath"   -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$genieGitURL$geniePlugins" -OutFile "$fullGenieFolderPath$geniePlugins"
    Write-Host "Downloading $geniePackage to $fullGenieFolderPath"   -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$genieGitURL$geniePackage" -OutFile "$fullGenieFolderPath$geniePackage"
    if ($buildanswer -eq "3") {
        Write-Host "Downloading $windowsdesktopruntimeFilename to $fullGenieFolderPath"   -ForegroundColor Yellow
        Invoke-WebRequest -Uri "$windowsdesktopruntimeSource" -OutFile "$fullGenieFolderPath$windowsdesktopruntimeFilename"
    }
    Write-Host "" 
    Write-Host "File download completed..." -ForegroundColor Green
    #extracts the stuff in order
    Write-Host "" 
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    Write-Host "" 
    Write-Host "Extract the ZIP files to:   $fullGenieFolderPath ?"   -ForegroundColor Yellow
    Write-Host "" 
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    PromptYesNo
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    Write-Host "" 
    Write-Host "Extracting $genieConfigFiles to $fullGenieFolderPath"   -ForegroundColor Yellow
    Expand-Archive -LiteralPath "$fullGenieFolderPath$genieConfigFiles" -DestinationPath "$fullGenieFolderPath"
    Write-Host "Extracting $geniePlugins to $fullGenieFolderPath"   -ForegroundColor Yellow
    Expand-Archive -LiteralPath "$fullGenieFolderPath$geniePlugins" -DestinationPath "$fullGenieFolderPath\Plugins" -Force
    Write-Host "Extracting $geniePackage to $fullGenieFolderPath"   -ForegroundColor Yellow
    Expand-Archive -LiteralPath "$fullGenieFolderPath$geniePackage" -DestinationPath "$fullGenieFolderPath"
    Write-Host "" 

    if (Test-Path $fullGenieFolderPath) {
        $folderfilecount = (Get-ChildItem -Path $fullGenieFolderPath -File | Measure-Object).Count
        if ($folderfilecount -gt 3){
            Write-Host "Extraction of files was completed..." -ForegroundColor Green
        }
        if ($folderfilecount -eq 3){
            Write-Host "Unable to extract the files properly..." -ForegroundColor Red
            Write-Host ""
            exit
        }
    }

    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    #deletes the files
    Write-Host ""
    Write-Host "Cleanup: Removing the ZIP Files downloaded in $fullGenieFolderPath"   -ForegroundColor Yellow
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    PromptYesNo
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host ""
    Write-Host "Removing $genieConfigFiles from $fullGenieFolderPath"   -ForegroundColor Yellow
    remove-item $fullGenieFolderPath$genieConfigFiles -Force
    Write-Host "Removing $geniePlugins from $fullGenieFolderPath"   -ForegroundColor Yellow
    remove-item $fullGenieFolderPath$geniePlugins -Force
    Write-Host "Removing $geniePackage from $fullGenieFolderPath"   -ForegroundColor Yellow
    remove-item $fullGenieFolderPath$geniePackage -Force
    Write-Host "" 
    Write-Host "Downloaded file cleanup completed..." -ForegroundColor Green
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    Write-Host ""
    if ($buildanswer -eq "3") {
        Write-Host "IMPORTANT: Option 3: x64 Runtime Dependent Related" -ForegroundColor Yellow
        Write-Host "Please make sure to run $windowsdesktopruntimeFilename prior to running Genie.exe!" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Opening $fullGenieFolderPath..."
    Invoke-Item "$fullGenieFolderPath"
    Write-Host ""
    Write-Host "END of Script!" -ForegroundColor Green 
    Write-Host "Please verify that Genie.exe launches successfully! Enjoy!" -ForegroundColor Green
    exit
}