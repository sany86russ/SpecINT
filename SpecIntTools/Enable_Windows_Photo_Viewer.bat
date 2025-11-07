@echo off
:: проверяем, запущен ли батник от админа
net session >nul 2>&1
if %errorlevel%==0 goto :admin

:: если не админ — перезапускаем себя с правами
echo Запрашиваю права администратора...
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /b

:admin
echo Импортирую ключи реестра...
reg import "%~dp0Enable_Windows_Photo_Viewer.reg"
echo Готово.
pause
