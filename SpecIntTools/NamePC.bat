@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM --- HARD: force command echo off even if it was enabled outside ---
echo off

REM --- Save current code page (for rollback) ---
for /f "tokens=2 delims=:" %%A in ('chcp') do set "OLDCP=%%A"
set "OLDCP=%OLDCP: =%"

REM --- Try UTF-8 first (Cyrillic), fallback to OEM 866 ---
chcp 65001 >nul 2>&1
if errorlevel 1 chcp 866 >nul 2>&1

REM --- Green text ---
color 0A

set "PC=%COMPUTERNAME%"
set "COPIED=0"

cls
echo ============================================================
echo   ВАШЕ ИМЯ КОМПЬЮТЕРА: %PC%
echo ============================================================
echo(
echo Выберите действие:
echo   [1] Скопировать имя ПК и ЗАКРЫТЬ окно
echo   [2] Скопировать имя ПК и ОСТАТЬСЯ в окне
echo(
echo Как вставить в любом чате:
echo   - Ctrl+V
echo   - или Shift+Insert
echo(

choice /c 12 /n /m "Нажмите 1 или 2: "
set "SEL=%errorlevel%"

call :CopyToClipboard "%PC%"

echo(
if "%COPIED%"=="1" (
  echo [СТАТУС] OK: Имя ПК скопировано в буфер обмена.
) else (
  echo [СТАТУС] ОШИБКА: Не удалось скопировать в буфер обмена.
  echo          Имя ПК показано выше — можно выделить и скопировать вручную.
)

echo(
echo Подсказка: теперь откройте нужный чат и нажмите Ctrl+V.
echo(

if "%SEL%"=="1" goto :EXITNOW
pause >nul

:EXITNOW
if defined OLDCP chcp %OLDCP% >nul 2>&1
endlocal
exit /b


:CopyToClipboard
set "COPIED=0"

REM 1) clip (Win10/11)
echo %~1 | clip >nul 2>&1
if not errorlevel 1 (set "COPIED=1" & exit /b)

REM 2) PowerShell (если установлен)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Clipboard -Value '%~1'" >nul 2>&1
if not errorlevel 1 (set "COPIED=1" & exit /b)

REM 3) mshta fallback (Win7-11)
mshta "javascript:try{var s='%~1';var d=document;d.body=createElement('body');d.body.innerText=s;d.execCommand('Copy');}catch(e){};close();" >nul 2>&1
if not errorlevel 1 set "COPIED=1"

exit /b
