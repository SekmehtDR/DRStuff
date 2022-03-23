###########################################
#-----------------------------------------#
#---By-Sekmeht-16MAR2021------------------#
#---https://github.com/SekmehtDR/DRstuff--#
#-----------------------------------------#
###########################################

#Location of Genie Root Folder (Default: C:\temp\)?
$genieInstallRootFolder = "C:\"

#Github Release URL Info - Important to update the numeric value in the download URL below
$releaseDownloadURL = "https://github.com/GenieClient/Genie4/releases/download/4.0.2.3/"
$releaseDownloadURL -match 'https://github.com/(?<GithubUser>.*)/(?<GithubRepo>.*)/releases/download/(?<Version>.*)/'

#Git Repo Stuff
$gitHubUser = $Matches.GithubUser
$gitHubRepo = $Matches.GithubRepo
$gitHubVersion = $Matches.Version
$genieGitURL = "https://github.com/$gitHubUser/$gitHubRepo/releases/download/$gitHubVersion/"

#GenieMaps Location:
$genieMapsURL = "https://github.com/GenieClient/Maps/archive/refs/heads/"
$genieMapsGitHubZipfile = "main.zip"
$genieMapsFileURL = "$genieMapsURL$genieMapsGitHubZipfile"

#Where to migrate Genie folder from? (Default)
$genieMigrateRootFolder = ""

#Formatting of Genie FolderName (Genie Client <version without periods>. Ex. Genie Client 4020).
$genieVersionName = $gitHubVersion.Replace(".", "")
$genieFolderName = "Genie-$genieVersionName"

#Name of files in Repo, package specific stuff will be generated using a switch below
$genieConfigFiles = "Base.Config.Files.zip"
$geniePlugins = "Plugins.zip"
$genieMaps = "Main.zip"

#Parent Installation Path, change $genieInstallRootFolder
$fullGenieFolderPath = "$genieInstallRootFolder$genieFolderName"

#Microsoft Desktop Runtime Stuff
$windowsdesktopruntimeSource = "https://download.visualstudio.microsoft.com/download/pr/7f3a766e-9516-4579-aaf2-2b150caa465c/d57665f880cdcce816b278a944092965/windowsdesktop-runtime-6.0.3-win-x64.exe"
$windowsdesktopruntimeFilename = "WindowsDesktop-Runtime-6.0.3-win-x64.exe"

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

function installReadyYN {
    while ("yes","no" -notcontains $yorn_answer)
    {
        $yorn_answer = Read-Host "Ready to Install? (Yes/No)"
    }
        if ($yorn_answer -eq "no"){
            Write-Host "Exiting..." -ForegroundColor Red
        exit
        }
}

#START OF SCRIPT, MAIN MENU SELECTION
Clear-Host
Write-Host "-----------------------------------------------------"          -ForegroundColor Green
Write-Host "Genie 4 Toolkit"                                                -ForegroundColor Green
Write-Host "-----------------------------------------------------"          -ForegroundColor Green
Write-Host ""                                                               -ForegroundColor Green
Write-Host "Available Options:"                                             -ForegroundColor Yellow
Write-Host "- Option 1: UPDATE - GenieMaps $gitHubVersion"                  -ForegroundColor Yellow
Write-Host "- Option 2: Cancel"                                             -ForegroundColor Yellow
Write-Host "" 
$deploymentOption = Read-Host "Please make a numeric selection from the options above"
switch ($deploymentOption) {
    1 {$deploymentOption = "UpdateMaps"}
    2 {$deploymentOption = "Upgrade"}
    3 {$deploymentOption = "Migrate"}
    4 {
        Write-Host "Canceling..."                                     -ForegroundColor Red
        exit
    }
    default{
        Write-Host "No Match Found..."
        exit
    }
}
### Option 1: Install Start ###
Write-Host "$deploymentOption"

if ($deploymentOption -eq "UpdateMaps"){
    Clear-Host
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host "Option 1: UPDATE - GenieMaps"
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host ""
    Write-Host "- G4 Maps URL:            $genieMapsURL"                -ForegroundColor Yellow
    write-Host "- GenieMaps:              $genieMapsGitHubZipfile"      -ForegroundColor Yellow
    Write-Host ""     -ForegroundColor Yellow             
    Write-Host "- Genie Maps Path:        $fullGenieFolderPath\Maps"    -ForegroundColor Yellow
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    PromptYesNo
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host ""
    Write-Host "Checking if folder exists..."             -ForegroundColor Yellow
    Write-Host ""
    if (Test-Path "$fullGenieFolderPath\Maps") {
        Write-Host "- Folder exists... continuing..." -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "- Folder does not exist...exiting..." -ForegroundColor Red
        Write-Host ""
        pause
        exit
    } 
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green
    Write-Host ""
    Write-Host "Downloading files: via Invoke-WebRequest..."             -ForegroundColor Yellow
    Write-Host ""
    Write-Host "- G4 Maps URL:            $genieMapsURL"              -ForegroundColor Yellow
    write-Host "- GenieMaps:              $genieMapsGitHubZipfile"        -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Downloading $genieMaps to $fullGenieFolderPath"   -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$genieMapsURL$genieMapsGitHubZipfile" -OutFile "$fullGenieFolderPath\$genieMapsGitHubZipfile"
    Write-Host "" 
    Write-Host "File download completed..." -ForegroundColor Green
    Write-Host "" 
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    Write-Host "" 
    Write-Host "Extract ZIP files to:   $fullGenieFolderPath\Maps"   -ForegroundColor Yellow
    Write-Host "" 
    Write-Host "- CleanUp Maps Directory in $fullGenieFolderPath\Maps"   -ForegroundColor Yellow
    Remove-Item "$fullGenieFolderPath\Maps\*"  -Recurse -Force
    Write-Host "- Extracting $genieMaps to $fullGenieFolderPath"   -ForegroundColor Yellow
    Expand-Archive -LiteralPath "$fullGenieFolderPath\$genieMapsGitHubZipfile" -DestinationPath "$fullGenieFolderPath\Maps"
    Write-Host "" 

    if (Test-Path "$fullGenieFolderPath\Maps") {
        $folderfilecount = (Get-ChildItem -Path $fullGenieFolderPath -File | Measure-Object).Count
        if ($folderfilecount -gt 3){
            Write-Host "Extraction of files was completed..." -ForegroundColor Green
        }
        if ($folderfilecount -eq 0){
            Write-Host "Unable to extract the files properly..." -ForegroundColor Red
            Write-Host ""
            exit
        }
    } else {
        Write-Host "Something went wrong..."
        exit
    }
    

    #deletes the files
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    Write-Host ""
    Write-Host "Cleanup: Removing downloaded ZIP file(s)..."   -ForegroundColor Yellow
    Write-Host ""
    Write-Host "- Removing $genieMaps from $fullGenieFolderPath"   -ForegroundColor Yellow
    Remove-Item "$fullGenieFolderPath\$genieMaps" -Force
    Write-Host "" 
    Write-Host "Downloaded file cleanup completed..." -ForegroundColor Green
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    Write-Host ""
    Write-Host "Post-install processing..."   -ForegroundColor Yellow
    Write-Host ""
    Write-Host "- Genie Map Update... Processing..."   -ForegroundColor Yellow
    Copy-Item "$fullGenieFolderPath\Maps\Maps-main\*" "$fullGenieFolderPath\Maps" -Recurse -Force
    Remove-Item "$fullGenieFolderPath\Maps\Maps-main"  -Recurse -Force
    Copy-Item "$fullGenieFolderPath\Maps\Festivals Copy to the Maps Folder\*" "$fullGenieFolderPath\Maps" -Recurse -Force
    Copy-Item "$fullGenieFolderPath\Maps\Quests (Spoiler Alert) Copy to the Maps Folder\*" "$fullGenieFolderPath\Maps" -Recurse -Force
    Write-Host "- Genie Scripts Update... Processing..."   -ForegroundColor Yellow
    Copy-Item "$fullGenieFolderPath\Maps\Copy These to Genie's Scripts Folder\*" "$fullGenieFolderPath\Scripts" -Recurse -Force
    Write-Host "" 
    Write-Host "Post-install processing completed..." -ForegroundColor Green
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    Write-Host "" 
    Write-Host "Opening $fullGenieFolderPath..."
    Invoke-Item "$fullGenieFolderPath"
    Write-Host ""
    Write-Host "END of Script! Enjoy" -ForegroundColor Green 
    Write-Host ""
    Write-Host "-----------------------------------------------------"  -ForegroundColor Green 
    pause
    exit
}

if ($deploymentOption -eq "Upgrade"){
    Write-Host ""
    Write-Host "Coming Soon" - -ForegroundColor Yellow
    PromptYesNo
    exit
}
if ($deploymentOption -eq "Migrate"){
    Write-Host ""
    Write-Host "Coming Soon" - -ForegroundColor Yellow
    PromptYesNo
    exit
}