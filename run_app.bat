@echo off
set "PATH=%PATH%;C:\flutter\bin"
echo checking for flutter...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Flutter command not found in PATH even after adding C:\flutter\bin.
    echo Please check your installation.
    echo.
    pause
    exit /b
)

echo Flutter found. Getting packages...
call flutter pub get

echo.
echo Running NEX App (Chrome)...
call flutter run -d chrome
pause
