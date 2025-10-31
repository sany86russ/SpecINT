@echo off
for /f "tokens=2 delims=:" %%a in ('chcp') do set "_cp=%%a"
chcp 65001 >nul

echo ===============================
echo   GPO + DHCP renew
echo   (user mode, no admin)
echo ===============================
echo.

echo 1) Обновление DNS
gpupdate /dnsresolve
echo.

echo 2) Перезапрос IP/DNS от DHCP:
ipconfig /release
ipconfig /renew
echo.

echo 3) Текущие параметры сети (фрагмент):
ipconfig | findstr /I "IPv4 DNS DHCP"
echo.

echo Готово. Перезапустите компьютер и проверьте работу ПК.
echo.

chcp %_cp% >nul
pause
