sudo echo "Options:"
echo -e "\t[I] Install HTTPS VirtualHost"
echo -e "\t[U] Unistall HTTPS VirtualHost"
read -p "Option:" option

# Instalar dependencias
#sudo apt install apache2 mod_ssl openssl


if [[ "$option" == "I" ]]; then
	# HTML index test
	sudo mkdir -p /var/www/html/
	sudo sh -c 'echo "<h1>Conexion SSL</h1>" > /var/www/html/index.html'

	# Add VirtualHost info to httpd configuration on port 443
	ipaddr=$(ip addr | grep "inet " | cut -d " " -f 6 | cut -d "/" -f 1 | grep -v -E "^127|^172")
	grep "SSLCertificateFile /etc/pki/tls/certs/certificado.crt" /etc/httpd/conf/httpd.conf &> /dev/null
	if [[ "$?" == "1"  ]]; then	
		sudo sh -c 'echo "<VirtualHost *:80 *:443>" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "SSLEngine on" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "SSLCertificateFile /etc/pki/tls/certs/certificado.crt" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "SSLCertificateKeyFile /etc/pki/tls/private/llave.key" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "SSLCertificateChainFile /etc/pki/ca-trust/extracted/pem/server.csr" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "ServerName www.ejemplo.com" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "DocumentRoot /var/www/html/" >> /etc/httpd/conf/httpd.conf'
		sudo sh -c 'echo "</VirtualHost>" >> /etc/httpd/conf/httpd.conf'
	fi
	ls /etc/pki/tls/certs/certificado.crt &> /dev/null
	if [[ "$?" == "1" ]]; then
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
		sudo mv certificado.crt /etc/pki/tls/certs/
		sudo mv llave.key /etc/pki/tls/private/
		sudo mv server.csr /etc/pki/ca-trust/extracted/pem/
	fi
	# Restart httpd server
	sudo systemctl restart httpd
	echo -e "\nHttps server listening on --> https://"$ipaddr":443"

fi
#Uninstall Server
if [[ "$option" == "U" ]]; then
	lines=$(wc -l /etc/httpd/conf/httpd.conf | cut -d " " -f 1)
	sudo sh -c 'head /etc/httpd/conf/httpd.conf -n $(($lines-8)) > /etc/httpd/conf/httpd.conf'
	sudo rm /etc/pki/tls/certs/certificado.crt
	sudo rm /etc/pki/tls/private/llave.key
	sudo rm /etc/pki/ca-trust/extracted/pem/server.csr
fi
#sudo openssl s_server -key /etc/pki/tls/private/llave.key -cert /etc/pki/tls/certs/certificado.crt -cert_chain /etc/pki/ca-trust/extracted/pem/server.csr -accept 443 -port 443 -HTTP /var/www/html/index.html
#sudo openssl s_server -key /etc/pki/tls/private/llave.key -cert /etc/pki/tls/certs/certificado.crt -accept 443 -HTTP /var/www/html/index.html
