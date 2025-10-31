@echo off
for /f "tokens=2 delims=:" %%a in ('chcp') do set "_cp=%%a"
chcp 65001 >nul

:: Renew-IP-User.bat — обновить IP/DNS по DHCP без прав администратора.
:: Работает под обычной учёткой: выполняет ipconfig /release и /renew.
:: Примечание: очистка кэша DNS (flushdns) и смена DNS-серверов требуют прав Администратора.

setlocal
echo ===============================
echo   DHCP renew (user mode)
echo ===============================

echo 1) Освобождение адреса (ipconfig /release)...
ipconfig /release
echo.

echo 2) Запрос нового адреса и DNS от DHCP (ipconfig /renew)...
ipconfig /renew
echo.

echo 3) Текущие параметры сети (фрагмент):
ipconfig | findstr /I "IPv4 DNS DHCP"
echo.
echo Готово. Перезапустите компьютер и проверьте работу ПК
chcp %_cp% >nul
pause
