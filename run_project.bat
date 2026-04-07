@echo off
set "PATH=%PATH%;C:\flutter\bin"

echo ==========================================
echo       NEX Project Launcher
echo ==========================================

echo [1/2] Starting Backend Server...
start "NEX Backend API" cmd /k "cd /d ..\nex_backend && call .venv\Scripts\activate.bat && python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

echo Backend started in new window.
echo Waiting 5 seconds for backend initialization...
timeout /t 5 >nul

echo [2/2] Starting Flutter Frontend...
echo - Check Chrome browser for the app
echo - Navigate to Manager Dashboard -> Estate -> Block Map (3rd icon)
call flutter run -d chrome

pause
