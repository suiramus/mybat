# Instrucțiuni pentru generarea directorului și configurare SSL, vhost, host

Acest script generează un director pe baza promptului și creează fișierele necesare pentru vhost, host în Windows, `.htaccess`, `vhost.conf`, `index.php` și certificate SSL (dacă se dorește).

## 1. Cerințe preliminare
- XAMPP in Windows
- Apache > 2.4 (important pentru httpd-vhost.conf si pentru .htaccess)
- Copiati fisierul .bat in locul unde vreti sa fie generat directorul. mysite.loc/
- Asigurați-vă că aveți instalat [mkcert](https://github.com/FiloSottile/mkcert) dacă doriți să generați certificate SSL.

## 2. Utilizare

1. Rulați scriptul în linia de comandă Windows.

2. Introduceți domeniul dorit la prompt:
	```sh
	Introdu domeniul (ex: mysite.loc):
	```

3. Dacă domeniul nu este specificat, scriptul se va opri:
	```sh
	Domeniul nu a fost specificat. Scriptul se opreste.
	```

4. Numele domeniului va fi afișat:
	```sh
	Numele domeniului este mysite.loc
	```

## 3. Configurarea variabilelor de cale

- DocumentRoot și locația fișierului vhost vor fi setate automat:
	```sh
	set document_root=%cd%\%sitename%
	set VHOST_FILE=%cd%\%sitename%\vhost.conf
	set INDEX_FILE=%cd%\%sitename%\index.php
	set HTACCESS_FILE=%cd%\%sitename%\.htaccess
	```

## 4. Generarea certificatelor SSL

1. Utilizatorul va fi întrebat dacă dorește să genereze certificate SSL:
	```sh
	Vreti sa generati certificatul SSL? (Y/N):
	```

2. Dacă răspunsul este "N", certificatul nu va fi generat:
	```sh
	Certificatul SSL NU a fost generat.
	```

3. Dacă răspunsul este "Y", scriptul va verifica dacă `mkcert` este instalat și va genera certificatele:
	```sh
	Certificatul SSL a fost generat in mysite.loc/ssl/
	```
4. Certificatele SSL vor fi adaugate in mysite.loc/ssl/
	- `/mysite.loc/ssl/mysite.loc.pem`
	- `/mysite.loc/ssl/mysite.loc-key.pem`
	
5. Certificatele vor fi valabile pentru `mysite.loc`, `www.mysite.loc` si `*.mysite.loc` 
6. Certificatele sunt emise pe 2 ani. Daca se doreste prelungirea lor:
	```sh
	mkcert -cert-file "%sitename%.pem" -key-file "%sitename%-key.pem" -expire=87600h "%sitename%" "www.%sitename%" "*.%sitename%"
	:: Explicația parametrului -expire=87600h:
	:: 87600h reprezintă 10 ani (10 ani * 365 zile/an * 24 ore/zi = 87600 ore).
	```


## 5. Configurarea vhost

1. Fișierul `vhost.conf` va fi creat pentru porturile 80 și 443:
	```sh
	# =========================== 
	# Instructiuni pentru C:\xampp\apache\conf\extra 
	# Sitename: mysite.loc 
	# DocumentRoot: D:\www\mysite.loc 
 
	<VirtualHost *:80>
		ServerAdmin webmaster@mysite.loc
		ServerName mysite.loc
		ServerAlias www.mysite.loc
		DocumentRoot D:\www\mysite.loc
		<Directory "D:\www\mysite.loc">
			AllowOverride All
			Require all granted
		</Directory>
		Redirect permanent / https://www.mysite.loc/
	</VirtualHost>
	<VirtualHost *:443>
		ServerAdmin webmaster@mysite.loc
		ServerName mysite.loc
		ServerAlias www.mysite.loc
		DocumentRoot D:\www\mysite.loc
		<Directory "D:\www\mysite.loc">
			AllowOverride All
			Require all granted
		</Directory>
		SSLEngine on
		SSLCertificateFile "D:\www\mysite.loc\ssl\mysite.loc.pem"
		SSLCertificateKeyFile "D:\www\mysite.loc\ssl\mysite.loc-key.pem"
	</VirtualHost>
 
	# =========================== 

	# ===========================
	# C:\Windows\System32\drivers\etc
	# mysite.loc
	# 127.0.0.1 mysite.loc
	# 127.0.0.1 www.mysite.loc
	# ::1 mysite.loc
	# ::1 www.mysite.loc
	# ===========================
	```

## 6. Adăugarea intrărilor în fișierul hosts

- Intrările pentru fișierul hosts vor trebui adăugate in: C:\Windows\System32\drivers\etc\hosts
- Deschide cu Notepad -> Run as Administrator
	```sh
	# mysite.loc
	127.0.0.1 mysite.loc
	127.0.0.1 www.mysite.loc
	# ::1 mysite.loc
	# ::1 www.mysite.loc
	```

## 7. Crearea fișierului `index.php`

- Fișierul `index.php` va fi creat cu următorul conținut:
	```php
	<?php
	echo "mysite.loc";
	```

## 8. Generarea fișierului `.htaccess`

1. Scriptul va genera fișierul `.htaccess` cu următorul conținut:
	```sh
	# ========== https + www ==========
	<IfModule mod_rewrite.c>
		RewriteEngine On
		RewriteCond %{HTTPS} off [OR]
		RewriteCond %{HTTP_HOST} !^www\. [NC]
		RewriteRule ^ https://www.%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
	</IfModule>
	# ========== https + www ==========
	```

## 9. Închiderea scriptului

- Scriptul se va închide automat după finalizarea tuturor operațiunilor:
	```sh
	Scriptul se va inchide!
	```

## 10. Structura fișierelor
	```sh
	D:\www\local-domain-generator.bat
	D:\www\mysite.loc\
		.htaccess
		index.php
		vhost.conf
		\ssl\
			mysite.loc-key.pem
			mysite.loc.pem
	```