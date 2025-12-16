@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

set "PSFILE=%TEMP%\NamePC_%RANDOM%.ps1"
if exist "%PSFILE%" del "%PSFILE%"

set "LINENUM=0"
for /f "usebackq delims=" %%a in ("%~f0") do (
    set /a LINENUM+=1
    if !LINENUM! gtr 14 echo %%a>> "%PSFILE%"
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%" >nul 2>&1
endlocal
goto :eof

$AdminEmail = "chaikin_aa@ukpomosch.ru"
$EncryptKey = "SpecIntadmin2025ru#"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

# ============================================================
# POWER SETTINGS - High Performance, Never Sleep
# ============================================================

Write-Host "============================================================"
Write-Host "      CONFIGURING POWER SETTINGS..."
Write-Host "============================================================"
Write-Host ""

$powerSuccess = $true

try {
    # GUID schemes
    $highPerf = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    $balanced = "381b4222-f694-41f0-9685-ff5bb260df2e"

    # Check if High Performance scheme exists
    $schemes = powercfg /list 2>$null
    $hasHighPerf = $schemes -match $highPerf

    if ($hasHighPerf) {
        # Activate High Performance
        powercfg /setactive $highPerf 2>$null
        Write-Host "[OK] High Performance scheme activated" -ForegroundColor Green
    } else {
        # Try to duplicate from balanced
        powercfg /duplicatescheme $balanced $highPerf 2>$null
        powercfg /setactive $highPerf 2>$null
        if ($LASTEXITCODE -ne 0) {
            # Use current scheme
            Write-Host "[i] Using current power scheme" -ForegroundColor Yellow
        } else {
            Write-Host "[OK] High Performance scheme created and activated" -ForegroundColor Green
        }
    }

    # Get active scheme GUID
    $activeScheme = (powercfg /getactivescheme) -replace '.*GUID:\s*([a-f0-9-]+).*','$1'

    # METHOD 1: powercfg /change (simple, works on most systems)
    Write-Host "[i] Setting display timeout to Never..." -ForegroundColor Cyan
    powercfg /change monitor-timeout-ac 0 2>$null
    powercfg /change monitor-timeout-dc 0 2>$null

    Write-Host "[i] Setting sleep timeout to Never..." -ForegroundColor Cyan
    powercfg /change standby-timeout-ac 0 2>$null
    powercfg /change standby-timeout-dc 0 2>$null

    Write-Host "[i] Setting hibernate timeout to Never..." -ForegroundColor Cyan
    powercfg /change hibernate-timeout-ac 0 2>$null
    powercfg /change hibernate-timeout-dc 0 2>$null

    Write-Host "[i] Setting disk timeout to Never..." -ForegroundColor Cyan
    powercfg /change disk-timeout-ac 0 2>$null
    powercfg /change disk-timeout-dc 0 2>$null

    # METHOD 2: powercfg /setacvalueindex (more precise)
    # Display off: SUB_VIDEO / VIDEOIDLE
    powercfg /setacvalueindex $activeScheme 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0 2>$null
    powercfg /setdcvalueindex $activeScheme 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0 2>$null

    # Sleep: SUB_SLEEP / STANDBYIDLE
    powercfg /setacvalueindex $activeScheme 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0 2>$null
    powercfg /setdcvalueindex $activeScheme 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0 2>$null

    # Hibernate: SUB_SLEEP / HIBERNATEIDLE
    powercfg /setacvalueindex $activeScheme 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0 2>$null
    powercfg /setdcvalueindex $activeScheme 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0 2>$null

    # Disk off: SUB_DISK / DISKIDLE
    powercfg /setacvalueindex $activeScheme 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0 2>$null
    powercfg /setdcvalueindex $activeScheme 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0 2>$null

    # Apply changes
    powercfg /setactive $activeScheme 2>$null

    # METHOD 3: Disable hibernate completely (optional, saves disk space)
    powercfg /hibernate off 2>$null

    Write-Host "[OK] Power settings configured!" -ForegroundColor Green

} catch {
    Write-Host "[WARNING] Some power settings may not be applied: $_" -ForegroundColor Yellow
    $powerSuccess = $false
}

Write-Host ""
Start-Sleep -Seconds 1

# ============================================================
# COLLECT PC INFO
# ============================================================

$PC = $env:COMPUTERNAME
$User = $env:USERNAME
$Domain = $env:USERDOMAIN
$DateTime = Get-Date -Format "dd.MM.yyyy HH:mm"

$IP = "Not found"
try {
    $addr = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -match "^(192\.168\.|10\.|172\.)" }
    if ($addr) { $IP = $addr[0].IPAddress }
} catch { }

Clear-Host
Write-Host "============================================================"
Write-Host "      INFORMACIYA O VASHEM COMPUTERE"
Write-Host "============================================================"
Write-Host ""
Write-Host "  PC Name:           $PC"
Write-Host "  Local IP:          $IP"
Write-Host "  User:              $Domain\$User"
Write-Host "  Date:              $DateTime"
if ($powerSuccess) {
    Write-Host "  Power Settings:    [OK] Configured" -ForegroundColor Green
} else {
    Write-Host "  Power Settings:    [!] Partial" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "============================================================"
Write-Host ""
Write-Host "Vvedite parol ot CAN:"
Write-Host ""
Write-Host ""

$Comment = Read-Host ">"
if ([string]::IsNullOrWhiteSpace($Comment)) { $Comment = "-" }

Clear-Host
Write-Host ""
Write-Host "============================================================"
Write-Host "  Encrypting and creating email..."
Write-Host "============================================================"
Write-Host ""
Write-Host "  To: $AdminEmail"
Write-Host ""

Write-Host "Encrypting comment..." -ForegroundColor Cyan
try {
    $salt = [byte[]](83,112,101,99,73,110,116,50,48,50,53,82,117,83,97,108)
    $keyGen = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($EncryptKey, $salt, 10000)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $keyGen.GetBytes(32)
    $aes.IV = $keyGen.GetBytes(16)
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $enc = $aes.CreateEncryptor()
    $bytes = [Text.Encoding]::UTF8.GetBytes($Comment)
    $encBytes = $enc.TransformFinalBlock($bytes, 0, $bytes.Length)
    $aes.Dispose()
    $EncryptedComment = [Convert]::ToBase64String($encBytes)
    Write-Host "[OK] Encrypted" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] $_" -ForegroundColor Red
    $EncryptedComment = "ERROR"
}

Write-Host ""
Write-Host "Checking Outlook..." -ForegroundColor Cyan

try {
    $outlook = New-Object -ComObject Outlook.Application
    Write-Host "[OK] Outlook found" -ForegroundColor Green
    Write-Host ""
    Write-Host "Creating email..." -ForegroundColor Cyan
    $mail = $outlook.CreateItem(0)
    $mail.To = $AdminEmail
    $mail.Subject = "PC Moving: $PC"
    $body = "PC Name:      $PC`r`n"
    $body += "IP:     $IP`r`n"
    $body += "User:         $Domain\$User`r`n"
    $body += "Date:         $DateTime`r`n"
    $body += "Power:        Configured (High Performance, Never Sleep)`r`n"
    $body += "----------------------------`r`n"
    $body += "PasswordCAN:`r`n"
    $body += "$EncryptedComment"
    $mail.Body = $body
    $mail.Display()
    Write-Host ""
    Write-Host "[OK] Email opened in Outlook!" -ForegroundColor Green
    Write-Host "Click SEND." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
} catch {
    Write-Host "[ERROR] Outlook not found!" -ForegroundColor Red
    $clip = "PC: $PC | IP: $IP | User: $Domain\$User | Comment: $EncryptedComment"
    Set-Clipboard -Value $clip
    Write-Host "Data copied to clipboard." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to close..."
    Read-Host
}
