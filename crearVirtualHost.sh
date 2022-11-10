ipaddr=$(ip addr | grep "inet " | cut -d " " -f 6 | cut -d "/" -f 1 | grep -v -E "^127|^172")
config="/etc/apache2/sites-enabled/example.conf"
#sudo rm /ect/apahce2/sites-enabled/*
sudo touch $config

#ssh-keygen -t rsa -b 2048

#/var/spool/cron/<crontabs>
#sudo systemctl start/enable cronie
#min hora diames mes diasemana ruta_script

grep "SSLCertificateFile /etc/pki/tls/certs/certificado.crt" $config &> /dev/null
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

if [[ "$option" == "I" ]]; then
        # Install dependencies
        echo "[*] Instalando dependencias"
        sudo apt install apache2 openssl -y &> /dev/null
        sudo a2enmod ssl
        #sudo a2enmod rewrite

        # HTML index test
        sudo mkdir -p /var/www/html/
        sudo sh -c 'echo "<h1>Conexion SSL</h1>" > /var/www/html/index.html'

        # Give the users permisions to /var/www/html/
        sudo chmod 777 -R /var/www/html/

        # Add VirtualHost info to httpd configuration on port 443
        grep "SSLCertificateFile /etc/pki/tls/certs/certificado.crt" $config &> /dev/null
        if [[ "$?" != "0"  ]]; then
                sudo sh -c 'echo "<VirtualHost *:80>" >> '$config
                sudo sh -c 'echo "      Redirect / https://'$(curl ifconfig.me)'" >> '$config
                sudo sh -c 'echo "</VirtualHost>" >> '$config
                sudo sh -c 'echo "" >> '$config
                sudo sh -c 'echo "<VirtualHost *:443>" >> '$config
                sudo sh -c 'echo "      SSLEngine on" >> '$config
                sudo sh -c 'echo "      SSLCertificateFile /etc/pki/tls/certs/certificado.crt" >> '$config
                sudo sh -c 'echo "      SSLCertificateKeyFile /etc/pki/tls/private/llave.key" >> '$config
                sudo sh -c 'echo "      SSLCertificateChainFile /etc/pki/ca-trust/extracted/pem/server.csr" >> '$config
                sudo sh -c 'echo "      ServerAdmin example@localhost.com" >> '$config
                sudo sh -c 'echo "      <Directory /var/www/html/>" >> '$config
                sudo sh -c 'echo "              AllowOverride all" >> '$config
                sudo sh -c 'echo "      </Directory>" >> '$config
                sudo sh -c 'echo "      DocumentRoot /var/www/html/" >> '$config
                sudo sh -c 'echo "      ErrorLog /var/log/apache2/error.log" >> '$config
                sudo sh -c 'echo "      LogLevel warn" >> '$config
                sudo sh -c 'echo "      CustomLog /var/log/apache2/error.log combined" >> '$config
                sudo sh -c 'echo "</VirtualHost>" >> '$config
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
        sudo systemctl restart apache2
        echo -e "\nHttps server listening on:"
        echo -e "\t[*] https://$(curl ifconfig.me/):443 (usando la ip publica)"
        echo -e "\t[*] https://www.ejemplo.com:443 (usando un alias)"
        echo -e "\t[*] https://$ipaddr:443 (usando la ip privada)"

fi
#Uninstall Server
if [[ "$option" == "U" ]]; then
        # Uninstall dependencies
        read -p "Borrar dependencias: apache2 openssl [s/n]: " option
        if [[ "$option" == "s" ]]; then
                sudo apt remove apache2 openssl &> /dev/null
        else
                sudo systemctl restart apache2
        fi
        cat $config &> /dev/null
        if [[ "$?" == "0" ]]; then
                sudo rm $config
        fi
        sudo rm /etc/pki/tls/certs/certificado.crt &> /dev/null
        sudo rm /etc/pki/tls/private/llave.key &> /dev/null
        sudo rm /etc/pki/ca-trust/extracted/pem/server.csr &> /dev/null
        sudo chmod 755 -R /var/www/html/
        sudo systemctl restart apache2
fi
if [[ "$option" == "S" ]]; then
        systemctl status apache2
fi
if [[ "$option" == "R" ]]; then
        sudo systemctl restart apache2
fi
