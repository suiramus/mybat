@echo off
setlocal enabledelayedexpansion

:: Acest fisier genereaza un director pe baza promptului
:: De ex: mydomain.loc in directorul curent
:: Genereaza informatiile pentru vhost si host in Windows, fisierele .htaccess vhost.conf index.php
:: Genereaza certificate ssl in mydomain.loc/ssl/ (daca true)

:: ===========================
:: START DOMAIN

:: Cere utilizatorului să introducă domeniul
set /p sitename=Introdu domeniul (ex: mysite.loc): 
:: Verifică dacă domeniul este gol
if "%sitename%"=="" (
	echo Domeniul nu a fost specificat. Scriptul se opreste.
	pause
	exit /b
)
echo.
echo Numeledomeniului este %sitename%
echo.

:: END DOMAIN
:: ===========================

:: ===========================
:: START PATH VARIABLES

:: Setează DocumentRoot și locația fișierului vhost
set document_root=%cd%\%sitename%
set VHOST_FILE=%cd%\%sitename%\vhost.conf
set INDEX_FILE=%cd%\%sitename%\index.php
set HTACCESS_FILE=%cd%\%sitename%\.htaccess

:: END PATH VARIABLES
:: ===========================

:: ===========================
:: START SSL-CERTIFICATES

:: Variabilă pentru generarea certificatelor
:: Daca e true, se genereaza certificatele cu mkcert
:: Daca e fals, se sare peste mkcert (true or false)
set genereazaCertificat=true
:: Întreabă utilizatorul dacă vrea să genereze certificatul SSL
set /p raspuns=Vreti sa generati certificatul SSL? (Y/N): 

:: Verifică răspunsul utilizatorului
if /i "%raspuns%"=="N" (
	set genereazaCertificat=false
)

set SSL_DIR=%cd%\%sitename%\ssl
:: Creează directorul SSL dacă nu există
if not exist "%SSL_DIR%" mkdir "%SSL_DIR%" 

:: Verifică dacă mkcert este instalat (doar dacă genereazaCertificat este true)
if "%genereazaCertificat%"=="true" (
	:: Verifică dacă mkcert este instalat
	where mkcert >nul 2>nul
	if %errorlevel% neq 0 (
		echo Eroare: mkcert nu este instalat sau nu este în PATH.
		echo Descarcă-l de la https://github.com/FiloSottile/mkcert și instalează-l.
		pause
		exit /b
	)
	:: Generează certificatul SSL folosind mkcert
	cd /d "%SSL_DIR%"
	:: # mkcert -cert-file mysite.loc.pem -key-file mysite.loc-key.pem mysite.loc www.mysite.loc *.mysite.loc
	mkcert -cert-file "%sitename%.pem" -key-file "%sitename%-key.pem" "%sitename%" "www.%sitename%" "*.%sitename%"
	cd /d "%cd%"
)

if "%genereazaCertificat%"=="true" echo Certificatul SSL a fost generat in "%SSL_DIR%".

if "%genereazaCertificat%"=="false" echo Certificatul SSL NU a fost generat.

:: END SSL-CERTIFICATES
:: ===========================


:: ===========================
:: START VHOST

echo.
echo Se va genera fisierul vhost.conf, cu instructiuni de utilizare
echo.
pause

:: Creează fișierul de configurare pentru portul 80
echo # =========================== > "%VHOST_FILE%"
echo # Instructiuni pentru C:\xampp\apache\conf\extra >> "%VHOST_FILE%"
echo # Sitename: %sitename% >> "%VHOST_FILE%"
echo # DocumentRoot: %document_root% >> "%VHOST_FILE%"
echo. >> "%VHOST_FILE%"
(
	echo ^<VirtualHost *:80^>
	echo     ServerAdmin webmaster@%sitename%
	echo     ServerName %sitename%
	echo     ServerAlias www.%sitename%
	echo     DocumentRoot %document_root%
	echo     ^<Directory "%document_root%"^>
	echo         AllowOverride All
	echo         Require all granted
	echo     ^</Directory^>
	echo     Redirect permanent / https://www.%sitename%/
	echo ^</VirtualHost^>
) >> "%VHOST_FILE%"

:: Creează fișierul de configurare pentru portul 443 (HTTPS)
(
	echo ^<VirtualHost *:443^>
	echo     ServerAdmin webmaster@%sitename%
	echo     ServerName %sitename%
	echo     ServerAlias www.%sitename%
	echo     DocumentRoot %document_root%
	echo     ^<Directory "%document_root%"^>
	echo         AllowOverride All
	echo         Require all granted
	echo     ^</Directory^>
	echo     SSLEngine on
	echo     SSLCertificateFile "%SSL_DIR%\%sitename%.pem"
	echo     SSLCertificateKeyFile "%SSL_DIR%\%sitename%-key.pem"
	echo ^</VirtualHost^>
) >> "%VHOST_FILE%"
echo. >> "%VHOST_FILE%"
echo # =========================== >> "%VHOST_FILE%"
echo. >> "%VHOST_FILE%"

:: Adaugă intrările în fișierul hosts
(
	echo.	
	echo # ===========================
	echo # C:\Windows\System32\drivers\etc
	echo # %sitename%
	echo # 127.0.0.1 %sitename%
	echo # 127.0.0.1 www.%sitename%
	echo # ::1 %sitename%
	echo # ::1 www.%sitename%
	echo # ===========================
) >> "%VHOST_FILE%"

echo.
echo Fisierul de configurare pentru %sitename% a fost creat la: "%VHOST_FILE%"
echo.
pause

:: END VHOST
:: ===========================


:: ===========================
:: START INDEX.PHP
:: Adaugă index.php

echo ^<?php > "%INDEX_FILE%"
echo echo "%sitename%";  >> "%INDEX_FILE%"

:: END INDEX.PHP
:: ===========================


:: ===========================
:: START HTTACESS

echo. 
echo Se va genera fisierul htaccess!
echo. 
pause

setlocal disableDelayedExpansion
:: Genereaza fisierul htaccess
(
echo # ========== https + www ==========
echo ^<IfModule mod_rewrite.c^>
echo ^	RewriteEngine On
echo ^	RewriteCond %%{HTTPS} off [OR]
echo ^	RewriteCond %%{HTTP_HOST} !^^www\.^ [NC]
echo ^	RewriteRule ^^ https^://www.%%{HTTP_HOST}%%{REQUEST_URI} [L,R=301]
echo ^</IfModule^>
echo # ========== https + www ==========
) > %HTACCESS_FILE%
echo.
echo Fisierul htaccess a fost generat
echo.
pause

:: END HTTACESS
:: ===========================

echo.
echo Scriptul se va inchide!
echo.
pause

:: Închide scriptul
endlocal
endlocal
exit /b