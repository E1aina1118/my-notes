@echo off
REM Navigate to the directory where the script is located
cd /d "%~dp0"

REM Pull the latest changes from the remote repository
echo Pulling latest changes from remote...
git pull origin main

REM Add any new or modified files to the staging area
echo Adding changes to staging area...
git add .

REM Commit changes with a default message
echo Committing changes...
git commit -m "Auto-sync changes"

REM Push the changes to the remote repository
echo Pushing changes to remote repository...
git push origin main

REM Pause to see the output
echo Sync complete!
pause
