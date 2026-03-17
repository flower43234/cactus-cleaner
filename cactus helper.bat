@echo off
title CACTUS CLEANER v1.0 // BY CACTUS
color 0A
chcp 65001 >nul

:menu
cls
set "user_name=%USERNAME%"
:: Получаем версию ОС без лишних символов
for /f "tokens=4-6 delims= " %%a in ('ver') do set "os_ver=%%a %%b %%c"
:: Считаем свободное место
for /f "tokens=1-3 delims= " %%a in ('dir /-c c:\ ^| find "bytes free"') do set "free_space=%%c"
set /a free_gb=%free_space:~0,-9% 2>nul

echo.
echo [92m ██████╗ █████╗  ██████╗████████╗██╗   ██╗███████╗
echo ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔════╝
echo ██║     ███████║██║        ██║   ██║   ██║███████╗
echo ██║     ██╔══██║██║        ██║   ██║   ██║╚════██║
echo ╚██████╗██║  ██║╚██████╗   ██║   ╚██████╔╝███████║
echo  ╚═════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚══════╝[0m
echo.
echo  -----------------------------------------------------
echo  [97m TIME: %TIME:~0,5%  DATE: %DATE%  USER: %user_name%[0m
echo  [97m OS: Windows %os_ver:~0,-1%[0m
echo  [97m DISK C: %free_gb% GB FREE[0m
echo  -----------------------------------------------------
echo.
echo   [1] FULL CLEAN (Trash, Cache, Prefetch)
echo   [2] REGISTRY RESET (Shell, Userinit, Fix)
echo   [3] [93mTOTAL STARTUP MANAGER (Reg/Tasks/Folders)[0m
echo   [4] [32mADVANCED TWEAKS (Cortana, Telemetry, DNS)[0m
echo   [5] [96mSYSTEM OPTIMIZE (OneDrive, Power Plan, DVR)[0m
echo   [6] TURBO MODE (UI Optimization)
echo.
echo   [0] [91mEXIT[0m
echo.
echo [92mcactus@system:~# [0m

choice /c 1234560 /n
if errorlevel 7 exit
if errorlevel 6 goto turbo
if errorlevel 5 goto optimize
if errorlevel 4 goto advanced
if errorlevel 3 goto autorun_manager
if errorlevel 2 goto reset_reg
if errorlevel 1 goto clean

:autorun_manager
cls
echo [93m[ CACTUS: TOTAL STARTUP MANAGER ][0m
echo.
setlocal enabledelayedexpansion
set count=0
echo --- [ REGISTRY STARTUP ] ---
for /f "tokens=1,2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" ^| findstr "REG_"') do (
    set /a count+=1
    set "name[!count!]=%%a"
    set "type[!count!]=REG_CU"
    echo [!count!] %%a (User)
)
for /f "tokens=1,2*" %%a in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" ^| findstr "REG_"') do (
    set /a count+=1
    set "name[!count!]=%%a"
    set "type[!count!]=REG_LM"
    echo [!count!] %%a (System)
)
echo.
echo --- [ TASK SCHEDULER ] ---
for /f "tokens=1 delims=," %%t in ('schtasks /query /fo csv /nh ^| findstr /i "Ready"') do (
    set "task_raw=%%~t"
    echo !task_raw! | findstr /v "Microsoft Windows Google Update Adobe" >nul && (
        set /a count+=1
        set "name[!count!]=!task_raw!"
        set "type[!count!]=TASK"
        echo [!count!] !task_raw!
    )
)
echo.
echo [0] BACK TO MENU
echo.
set /p user_choice="cactus@startup:~# "
if "%user_choice%"=="0" endlocal & goto menu
if defined name[%user_choice%] (
    echo [+] Deleting !name[%user_choice%]!...
    if "!type[%user_choice%]!"=="REG_CU" reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "!name[%user_choice%]!" /f >nul 2>&1
    if "!type[%user_choice%]!"=="REG_LM" reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "!name[%user_choice%]!" /f >nul 2>&1
    if "!type[%user_choice%]!"=="TASK" schtasks /delete /tn "!name[%user_choice%]!" /f >nul 2>&1
    echo [!] Done. & pause
    endlocal & goto autorun_manager
)
endlocal & goto autorun_manager

:optimize
cls
echo [96m[ CACTUS: SYSTEM OPTIMIZATION ][0m
echo.
echo [1] Delete OneDrive (Complete Removal)
echo [2] Unlock Ultimate Performance Power Plan
echo [3] Disable Game DVR
echo.
echo [0] BACK TO MENU
echo.
choice /c 1230 /n
if errorlevel 4 goto menu
if errorlevel 3 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    echo [+] Game DVR Disabled. & pause & goto optimize
)
if errorlevel 2 (
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    echo [+] Ultimate Performance Unlocked. & pause & goto optimize
)
if errorlevel 1 (
    taskkill /f /im OneDrive.exe >nul 2>&1
    %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall >nul 2>&1
    %SystemRoot%\System32\OneDriveSetup.exe /uninstall >nul 2>&1
    echo [+] OneDrive Uninstalled. & pause & goto optimize
)

:advanced
cls
echo [32m[ CACTUS: ADVANCED TWEAKS ][0m
echo.
echo [1] Disable Cortana
echo [2] Disable Telemetry
echo [3] Set Cloudflare DNS
echo.
echo [0] BACK TO MENU
echo.
choice /c 1230 /n
if errorlevel 4 goto menu
if errorlevel 3 (
    for /f "tokens=3*" %%i in ('netsh interface show interface ^| findstr /C:"Connected"') do (
        netsh interface ip set dns name="%%j" source=static address=1.1.1.1
        netsh interface ip add dns name="%%j" addr=1.0.0.1 index=2
    )
    ipconfig /flushdns >nul
    echo [+] DNS Updated to 1.1.1.1. & pause & goto advanced
)
if errorlevel 2 (
    sc config DiagTrack start= disabled >nul 2>&1
    echo [+] Telemetry Disabled. & pause & goto advanced
)
if errorlevel 1 (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
    echo [+] Cortana Disabled. & pause & goto advanced
)

:clean
cls
echo [92m[ CACTUS: DESTROYING TRASH... ][0m
del /s /f /q %temp%\*.* >nul 2>&1
del /s /f /q C:\Windows\Temp\*.* >nul 2>&1
echo [+] Cleaned. & pause & goto menu

:reset_reg
cls
echo [91m[ CACTUS: RESTORING REGISTRY ][0m
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "explorer.exe" /f >nul 2>&1
echo [+] Restored. & pause & goto menu

:turbo
cls
echo [92m[ CACTUS: TURBO MODE ][0m
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul
echo [+] Applied. & pause & goto menu