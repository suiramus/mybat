# Instrucțiuni pentru generarea directorului și configurare SSL, vhost, host

Acest script generează un director pe baza promptului și creează fișierele necesare pentru vhost, host în Windows, `.htaccess`, `vhost.conf`, `index.php` și certificate SSL (dacă se dorește).

## 1. Cerințe preliminare

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
	Numeledomeniului este yourdomain.loc
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
	Certificatul SSL a fost generat in yourdomain.loc/ssl/
	```

## 5. Configurarea vhost

1. Fișierul `vhost.conf` va fi creat pentru porturile 80 și 443:
	```sh
	<VirtualHost *:80>
		ServerAdmin webmaster@yourdomain.loc
		ServerName yourdomain.loc
		ServerAlias www.yourdomain.loc
		DocumentRoot yourdomain
		<Directory "yourdomain">
			AllowOverride All
			Require all granted
		</Directory>
		Redirect permanent / https://www.yourdomain.loc/
	</VirtualHost>

	<VirtualHost *:443>
		ServerAdmin webmaster@yourdomain.loc
		ServerName yourdomain.loc
		ServerAlias www.yourdomain.loc
		DocumentRoot yourdomain
		<Directory "yourdomain">
			AllowOverride All
			Require all granted
		</Directory>
		SSLEngine on
		SSLCertificateFile yourdomain.loc/ssl/yourdomain.pem
		SSLCertificateKeyFile yourdomain.loc/ssl/yourdomain-key.pem
	</VirtualHost>
	```

## 6. Adăugarea intrărilor în fișierul hosts

- Intrările pentru fișierul hosts vor fi adăugate automat:
	```sh
	127.0.0.1 yourdomain.loc
	127.0.0.1 www.yourdomain.loc
	::1 yourdomain.loc
	::1 www.yourdomain.loc
	```

## 7. Crearea fișierului `index.php`

- Fișierul `index.php` va fi creat cu următorul conținut:
	```php
	<?php
	echo "yourdomain.loc";
	```

## 8. Generarea fișierului `.htaccess`

1. Scriptul va genera fișierul `.htaccess` cu următorul conținut:
	```sh
	<IfModule mod_rewrite.c>
		RewriteEngine On
		RewriteCond %{HTTPS} off [OR]
		RewriteCond %{HTTP_HOST} !^www\. [NC]
		RewriteRule ^ https://www.%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
	</IfModule>
	```

## 9. Închiderea scriptului

- Scriptul se va închide automat după finalizarea tuturor operațiunilor:
	```sh
	Scriptul se va inchide!
	```
