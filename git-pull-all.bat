@echo off
setlocal

for %%I in ("%~dp0.") do set "ROOT=%%~fI"
set "ROOT_DIR=%ROOT%\"
call :PullRepo "%ROOT%" "root repository"

for %%D in (api-gateway frontend shared-lib) do (
    if exist "%ROOT_DIR%%%~D" (
        call :PullRepo "%ROOT_DIR%%%~D" "%%~D"
    ) else (
        echo.
        echo Skipping %%~D: folder not found.
    )
)

for /d %%D in ("%ROOT_DIR%service-*") do (
    call :PullRepo "%%~fD" "%%~nxD"
)

echo.
echo Done.
endlocal
exit /b 0

:PullRepo
set "REPO_PATH=%~1"
set "REPO_NAME=%~2"

echo.
echo Pulling %REPO_NAME%...
git -C "%REPO_PATH%" pull
if errorlevel 1 (
    echo Failed to pull %REPO_NAME%.
    exit /b 1
)

exit /b 0