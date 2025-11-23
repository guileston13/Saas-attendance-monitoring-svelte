@echo off
cd /d "%~dp0"

echo Generating new SSL certificates for localhost...
echo.

REM Method 1: Using config file (recommended)
openssl req -x509 -new -nodes -newkey rsa:4096 -keyout localhost+1-key.pem -out localhost+1.pem -days 365 -config openssl.cnf

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Certificates generated successfully using config file!
    echo   - localhost+1-key.pem
    echo   - localhost+1.pem
    echo.
    echo Testing certificate...
    openssl x509 -in localhost+1.pem -noout -text | findstr /C:"Signature Algorithm" /C:"Public-Key" /C:"Subject:" /C:"DNS:" /C:"IP Address"
) else (
    echo.
    echo ✗ Failed with config file, trying direct method...
    echo.
    openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes ^
      -keyout localhost+1-key.pem ^
      -out localhost+1.pem ^
      -subj "/CN=localhost" ^
      -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1,IP:0.0.0.0,IP:192.168.1.64" ^
      -addext "keyUsage=digitalSignature,keyEncipherment" ^
      -addext "extendedKeyUsage=serverAuth"
    
    if %ERRORLEVEL% EQU 0 (
        echo ✓ Certificates generated with direct method!
    ) else (
        echo ✗ Failed to generate certificates
        echo   Make sure OpenSSL is installed and in your PATH
    )
)

echo.
pause
