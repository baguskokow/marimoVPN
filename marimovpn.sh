# Colors
white='\033[0m'
red='\033[1;31m'

# Status
failed="${red}FAILED${white}"
success="SUCCESS"
skipped="SKIPPED"

# working directory
workdir=/etc/ssl/marimocerts
log=/var/log/marimo.log
caDir=$workdir/ca
dhDir=$workdir/diffie-hellman
tlsDir=$workdir/tls
serverDir=$workdir/server
clientDir=$workdir/client

# Certificates
certificates=("ca.key" "ca.crt" "serial" "dh.pem" "ta.key" "server.key" "server.crt" "client.key" "client.crt")

# Time Duration
startTime=$(date +%s)

### Ensure Packages are installed

opensslVersion=$(openssl version | awk '{print $1 " = " "v"$2}')
openvpnVersion=$(openvpn --version | head -n 1 | awk '{print $1 " = " "v"$2}')

if [ $(echo $opensslVersion | grep -Eo OpenSSL) == "OpenSSL" ] && [ $(echo $openvpnVersion | grep -Eo OpenVPN) == "OpenVPN" ]; then
	echo -e "Ensuring Packages are Installed\t\t\t\t| $success | [ $opensslVersion ] & [ $openvpnVersion ]"
else
	echo -e "Ensuring Packages are Installed\t\t\t\t| $failed | Please Install openssl & openvpn!"
	exit
fi

# Checking Certificate Directory

ls /etc/ssl/ | grep marimocerts > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $workdir 2>> $log
	if [ $(echo $?) != 0 ]; then
		echo -e "Creating Certificate Directory\t\t\t\t| $failed "
		exit
	else
		echo -e "Creating Certificate Directory\t\t\t\t| $success "
	fi
else
	echo -e "Creating Certificate Directory\t\t\t\t| $skipped | Directory Already Exist"
fi

### Generate Root CA

# Checking "ca" directory
ls $workdir | grep ca > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $caDir 2> $log
	if [ $(echo $?) != 0 ]; then
		echo "Exited"
		exit
	fi
fi

# Checking certificate
ls $workdir/ca/ | grep ca.key > /dev/null && ls $workdir/ca/ | grep ca.crt > /dev/null

# Generate Certificate
if [ $(echo $?) != 0 ]; then
		openssl req -x509 -nodes -newkey rsa:2048 -keyout $caDir/${certificates[0]} -out $caDir/${certificates[1]} -subj "/C=ID/ST=Jakarta/O=marimovpn/CN=ROOT CA" 2>> $log && echo "01" | tee $caDir/${certificates[2]} > /dev/null
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating Root CA Certificate\t\t\t\t| $failed"
		exit
	else
		echo -e "Generating Root CA Certificate\t\t\t\t| $success"
	fi
else
	echo -e "Generating Root CA Certificate\t\t\t\t| $skipped | Certificate  Already Exist"
fi

### Generate Diffie–Hellman Key

# Checking Directory

ls $workdir | grep diffie-hellman > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $dhDir 2> $log
	if [ $(echo $?) != 0 ]; then
		echo "Exited"
		exit
	fi
fi

# Checking certificates

ls $dhDir | grep ${certificates[3]} > /dev/null

# Generate Key

if [ $(echo $?) != 0 ]; then
	openssl dhparam -out $dhDir/${certificates[3]} 2048 2> /dev/null
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating  Diffie–Hellman Key\t\t\t\t| $failed"
		exit
	else
		echo -e "Generating  Diffie–Hellman Key\t\t\t\t| $success"
	fi
else
		echo -e "Generating  Diffie–Hellman Key\t\t\t\t| $skipped | Key Already Exist"
fi

### Generate TLS Key

# Cheking Directory

ls $workdir | grep tls > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $tlsDir 2> $log
	if [ $(echo $?) != 0 ]; then
		echo "Exited"
		exit
	fi
fi

# Checking certificates

ls $tlsDir | grep ${certificates[4]} > /dev/null

# Generate Key

if [ $(echo $?) != 0 ]; then
	openvpn --genkey secret $tlsDir/${certificates[4]} 2> /dev/null
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating  TLS Key\t\t\t\t\t| $failed"
		exit
	else
		echo -e "Generating  TLS Key\t\t\t\t\t| $success"
	fi
else
		echo -e "Generating  TLS Key\t\t\t\t\t| $skipped | TLS Key Already Exist"
fi

### Generate Server Certificate

# Cheking Directory

ls $workdir | grep server > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $serverDir 2> $log
	if [ $(echo $?) != 0 ]; then
		echo "Exited"
		exit
	fi
fi

# Checking certificate
ls $serverDir | grep ${certificates[5]} > /dev/null && ls $serverDir | grep ${certificates[6]} > /dev/null

# Generate Certificate
if [ $(echo $?) != 0 ]; then
		openssl genrsa -out $serverDir/${certificates[5]} 2> /dev/null
		openssl req -new -key $serverDir/${certificates[5]} -out $serverDir/server.csr -subj "/C=ID/ST=Jakarta/O=OpenVPN-Server/CN=server" 2> /dev/null
		openssl x509 -req -in $serverDir/server.csr -out $serverDir/${certificates[6]} -CA $caDir/${certificates[1]} -CAkey $caDir/${certificates[0]} -CAserial $caDir/${certificates[2]} -days 365 2> /dev/null
		openssl verify -CAfile $caDir/${certificates[1]} $serverDir/${certificates[6]} > /dev/null
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating Server Certificate\t\t\t\t| $failed"
		exit
	else
		echo -e "Generating Server Certificate\t\t\t\t| $success"
	fi
else
	echo -e "Generating Server  Certificate\t\t\t\t| $skipped | Certificate  Already Exist"
fi

### Generate Client Certificate

# Cheking Directory

ls $workdir | grep client > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $clientDir 2> $log
	if [ $(echo $?) != 0 ]; then
		echo "Exited"
		exit
	fi
fi

# Checking certificate
ls $clientDir | grep ${certificates[7]} > /dev/null && ls $clientDir | grep ${certificates[8]} > /dev/null

# Generate Certificate
if [ $(echo $?) != 0 ]; then
		openssl genrsa -out $clientDir/${certificates[7]} 2> /dev/null
		openssl req -new -key $clientDir/${certificates[7]} -out $clientDir/client.csr -subj "/C=ID/ST=Jakarta/CN=client" 2> /dev/null
		openssl x509 -req -in $clientDir/client.csr -out $clientDir/${certificates[8]} -CA $caDir/${certificates[1]} -CAkey $caDir/${certificates[0]} -CAserial $caDir/${certificates[2]} -days 365 2> /dev/null
		openssl verify -CAfile $caDir/${certificates[1]} $clientDir/${certificates[8]} > /dev/null
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating Client Certificate\t\t\t\t| $failed"
		exit
	else
		echo -e "Generating Client Certificate\t\t\t\t| $success"
	fi
else
	echo -e "Generating Client  Certificate\t\t\t\t| $skipped | Certificate  Already Exist"
fi

### Ensuring config file is created

ls | grep config.txt > /dev/null

if [ $(echo $?) != 0 ]; then
	echo -e "Ensuring config file is created\t\t\t\t| $failed"
	echo "Exited"
	echo "Configuration File not yet created. Please create the config file!" >> $log
	exit
else
	echo -e "Ensuring config file is created\t\t\t\t| $success"
fi

# To do : Buat gimana caranya agar mendeteksi confignya itu benar atau salah

### Read from config.txt
port=$(cat config.txt | grep port | awk '{print $3}')
protocol=$(cat config.txt | grep protocol | awk '{print $3}')
serverIP=$(cat config.txt | grep ip | awk '{print $4}')
subnetTunnel=$(cat config.txt | grep subnet | awk '{print $4 " " $5}')

### Generate Configuration for OpenVPN Server

function serverConfiguration {
cat << EOF > /etc/openvpn/server.conf
### Generated by marimovpn ###

port $port
proto $protocol
dev tun
server $subnetTunnel
ca $caDir/ca.crt
cert $serverDir/server.crt
key $serverDir/server.key
dh $dhDir/dh.pem
ifconfig-pool-persist /var/log/openvpn/ipp.txt
<tls-crypt>
$(cat $tlsDir/ta.key)
</tls-crypt>
cipher AES-256-CBC
status /var/log/openvpn/openvpn-status.log
keepalive 10 120
persist-key
persist-tun
verb 3
explicit-exit-notify 1
EOF
}

### Generate Configuraton for Client

function clientConfiguration {
cat << EOF > /etc/openvpn/client/client.ovpn
### Generated by marimovpn ###

client
dev tun
proto udp
remote $serverIP $port
resolv-retry infinite
nobind
persist-key
persist-tun

<ca>
$(cat $caDir/ca.crt)
</ca>

<key>
$(cat $clientDir/client.key)
</key>

<cert>
$(cat $clientDir/client.crt)
</cert>

<tls-crypt>
$(cat $tlsDir/ta.key)
</tls-crypt>

cipher AES-256-CBC 
verb 3
EOF
}

### Ensuring if configuration server is exist

ls /etc/openvpn/ | grep server.conf > /dev/null

if [ $(echo $?) != 0 ]; then
	$(serverConfiguration)
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating Configuration File for Server\t\t| $failed"
		echo "Exited"
		exit
	else
		echo -e "Generating Configuration File for Server\t\t| $success"
	fi
else
	echo -e "Generating Configuration File for Server\t\t| $skipped | Configuration Server is exist\n"
	declare userInput
	read -p "You want to replace it with a new server configuration file? (y/n) " userInput
	if [ $userInput == 'y' ]; then
		$(serverConfiguration)
		echo -e "\nReplacing Configuration File for Server\t\t\t| $success"
	else
		echo -e "\nReplacing Configuration File for Server\t\t\t| $skipped"
	fi
fi

### Ensuring if configuration client is exist

ls /etc/openvpn/client | grep client.ovpn > /dev/null

if [ $(echo $?) != 0 ]; then
	$(clientConfiguration)
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating Configuration File for Client\t\t| $failed"
		echo "Exited"
		exit
	else
		echo -e "Generating Configuration File for Client\t\t| $success"
	fi
else
	echo -e "Generating Configuration File for Client\t\t| $skipped | Configuration Client is exist\n"
	declare userInput
	read -p "You want to replace it with a new client configuration file? (y/n) " userInput
	if [ $userInput == 'y' ]; then
		$(serverConfiguration)
		echo -e "\nReplacing Configuration File for Client\t\t\t| $success"
	else
		echo -e "\nReplacing Configuration File for Client\t\t\t| $skipped"
	fi
fi

# To do : Buat Agar bisa running servicenya & buat summary info ex: nama service, dll

### Elapsed Time

endTime=$(date +%s)
elapsedTime=$(($endTime - $startTime))

echo -e "\nElapsed Time : $elapsedTime seconds"
