@echo off
cd /d e:\projects
:again
echo.
echo.
echo ######################Choose Target Command#########################
echo ------------------------1. git pull---------------------------------
echo ------------------------2. git add+commit---------------------------
echo ------------------------3. git push---------------------------------
echo ------------------------4. git status-------------------------------
echo ------------------------5. INPUT q TO EXIT--------------------------


set /p num=

if "%num%"=="1" (
git pull
pause
goto again
)

if "%num%"=="2" (
goto gitcommit
)

if "%num%"=="3" (
git push
pause
goto again
)

if "%num%"=="4" (
git status
pause
goto again
)

if "%num%"=="q" (
exit
)

goto again

:gitcommit
git add .
set input=
set /p input=git commit info: 
echo output str: git commit info: %input%
git commit -m %input%
pause
goto again