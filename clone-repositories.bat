@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "BASE_DIR=%CD%"
set "DRY_RUN=0"
set "PULL_IF_EXISTS=0"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--dry-run" (
  set "DRY_RUN=1"
) else if /I "%~1"=="--pull" (
  set "PULL_IF_EXISTS=1"
) else (
  set "BASE_DIR=%~1"
)
shift
goto parse_args

:args_done
if not exist "%BASE_DIR%" (
  echo [ERROR] Base directory does not exist: %BASE_DIR%
  exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] git was not found in PATH.
  exit /b 1
)

echo Base directory: %BASE_DIR%
echo Dry run: %DRY_RUN%
echo Pull existing repos: %PULL_IF_EXISTS%
echo.

call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-api-gateway.git" "api-gateway"
call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-frontend.git" "frontend"
call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-achievements.git" "service-achievements"
call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-auth.git" "service-auth"
call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-clan.git" "service-clan"
call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-forum.git" "service-forum"
call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-service-learning.git" "service-learning"
call :clone_repo "https://github.com/advprog-2026-A15-project/yomu-shared-lib.git" "shared-lib"

echo.
echo Done.
exit /b 0

:clone_repo
set "REPO_URL=%~1"
set "REPO_DIR=%~2"
set "TARGET=%BASE_DIR%\%REPO_DIR%"

if exist "%TARGET%\.git" (
  echo [SKIP] %REPO_DIR% already exists as a git repo.
  if "%PULL_IF_EXISTS%"=="1" (
    if "%DRY_RUN%"=="1" (
      echo [DRY-RUN] git -C "%TARGET%" pull --ff-only
    ) else (
      git -C "%TARGET%" pull --ff-only
    )
  )
  goto :eof
)

if exist "%TARGET%" (
  echo [WARN] %REPO_DIR% exists but is not a git repo. Skipping.
  goto :eof
)

if "%DRY_RUN%"=="1" (
  echo [DRY-RUN] git clone "%REPO_URL%" "%TARGET%"
) else (
  echo [CLONE] %REPO_DIR%
  git clone "%REPO_URL%" "%TARGET%"
)

goto :eof
