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

#start of script
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