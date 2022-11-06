grep "SSLCertificateFile /etc/pki/tls/certs/certificado.crt" /etc/httpd/conf/httpd.conf &> /dev/null
if [[ "$?" == "0" ]]; then
	echo "HTTPS VirtualHost is installed"
else
	echo "HTTPS VirtualHost is not Installed"
fi
echo -e "\nOptions:"
echo -e "\t[I] Install HTTPS VirtualHost"
echo -e "\t[U] Unistall HTTPS VirtualHost"
echo -e "\t[S] Status httpd service"
echo -e "\t[R] Restart httpd service"
read -p "Option:" option

# Instalar dependencias
#sudo apt install apache2 mod_ssl openssl
#sudo pacman -Rncs apache
#sudo pacman -S apache


if [[ "$option" == "I" ]]; then
	# Give the users permisions to /var/www/html/
	sudo chmod 777 -R /var/www/html/

	# HTML index test
	sudo mkdir -p /var/www/html/
	sudo sh -c 'echo "<h1>Conexion SSL</h1>" > /var/www/html/index.html'
	
	#curl "https://svn.apache.org/repos/infra/websites/cms/webgui/conf/httpd.conf" > httpd.conf
	#sudo mv httpd.conf /etc/httpd/conf/httpd.conf

	# Add VirtualHost info to httpd configuration on port 443
	ipaddr=$(ip addr | grep "inet " | cut -d " " -f 6 | cut -d "/" -f 1 | grep -v -E "^127|^172")
	grep "SSLCertificateFile /etc/pki/tls/certs/certificado.crt" /etc/httpd/conf/httpd.conf &> /dev/null
	if [[ "$?" != "0"  ]]; then	
		sudo sh -c 'echo "127.0.0.1	www.ejemplo.com" >> /etc/hosts'
		sudo sh -c 'echo "Listen 443" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "<VirtualHost *:443>" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	SSLEngine on" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	SSLCertificateFile /etc/pki/tls/certs/certificado.crt" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	SSLCertificateKeyFile /etc/pki/tls/private/llave.key" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	SSLCertificateChainFile /etc/pki/ca-trust/extracted/pem/server.csr" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	ServerAdmin example@localhost.com" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	<Directory /var/www/html/>" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "		AllowOverride all" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	</Directory>" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	ServerName www.ejemplo.com" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	ServerAlias ejemplo.com" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	DocumentRoot /var/www/html/" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	ErrorLog /var/log/https_error.log" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	LogLevel warn" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "	CustomLog /var/log/https_error.log combined" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "</VirtualHost>" >> /etc/httpd/conf/httpd.conf'
	fi
	ls /etc/pki/tls/certs/certificado.crt &> /dev/null
	if [[ "$?" != "0" ]]; then
		# Remove Certificates if exists
		sudo rm /etc/pki/tls/certs/certificado.crt &> /dev/null
		sudo rm /etc/pki/tls/private/llave.key &> /dev/null
		sudo rm /etc/pki/ca-trust/extracted/pem/server.csr &> /dev/null
		# Generate new certificates
		sudo openssl genrsa -out llave.key 2048
		sudo openssl req -new -key llave.key -out server.csr
		sudo openssl x509 -req -days 365 -in server.csr -signkey llave.key -out certificado.crt
		# Move certificates to default dirs
		sudo mkdir -p /etc/pki/tls/certs/ &> /dev/null
		sudo mkdir -p /etc/pki/tls/private/ &> /dev/null
		sudo mkdir -p /etc/pki/ca-trust/extracted/pem/ &> /dev/null
		sudo mv certificado.crt /etc/pki/tls/certs/ &> /dev/null
		sudo mv llave.key /etc/pki/tls/private/ &> /dev/null
		sudo mv server.csr /etc/pki/ca-trust/extracted/pem/ &> /dev/null
	fi
	# Restart httpd server
	sudo systemctl restart httpd
	echo -e "\nHttps server listening on --> www.ejemplo.com"

fi
#Uninstall Server
if [[ "$option" == "U" ]]; then
	grep "SSLCertificateFile /etc/pki/tls/certs/certificado.crt" /etc/httpd/conf/httpd.conf &> /dev/null
	if [[ "$?" == "0" ]]; then
		lines=$(wc -l /etc/httpd/conf/httpd.conf | cut -d " " -f 1)
		lines=$(($lines-17))
		sudo head /etc/httpd/conf/httpd.conf -n $lines > tmp.txt
		sudo mv tmp.txt /etc/httpd/conf/httpd.conf
	fi
	grep "www.ejemplo.com" /etc/hosts &> /dev/null
	if [[ "$?" == "0" ]]; then
		lines=$(wc -l /etc/hosts | cut -d " " -f 1)
		lines=$(($lines-1))
		sudo head /etc/hosts -n $lines > tmp.txt
		sudo mv tmp.txt /etc/hosts
	fi
	sudo rm /etc/pki/tls/certs/certificado.crt &> /dev/null
	sudo rm /etc/pki/tls/private/llave.key &> /dev/null
	sudo rm /etc/pki/ca-trust/extracted/pem/server.csr &> /dev/null
	sudo chmod 755 -R /var/www/html/
fi
if [[ "$option" == "S" ]]; then
	systemctl status httpd
fi
if [[ "$option" == "R" ]]; then
	sudo systemctl restart httpd
fi
#sudo openssl s_server -key /etc/pki/tls/private/llave.key -cert /etc/pki/tls/certs/certificado.crt -cert_chain /etc/pki/ca-trust/extracted/pem/server.csr -accept 443 -port 443 -HTTP /var/www/html/index.html
#sudo openssl s_server -key /etc/pki/tls/private/llave.key -cert /etc/pki/tls/certs/certificado.crt -accept 443 -HTTP /var/www/html/index.html
