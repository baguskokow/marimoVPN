workdir=/etc/ssl/marimocerts
log=./log/marimo.log
caDir=$workdir/ca

# Checking Certificate Directory

ls /etc/ssl/marimocerts/ 2> /dev/null
if [ $(echo $?) != 0 ]; then
	mkdir $workdir 2>> $log
	if [ $(echo $?) != 0 ]; then
		echo "Creating Certificate Directory | FAILED "
		exit
	else
		echo "Creating Certificate Directory | SUCCESS "
	fi
else
	echo "Creating Certificate Directory | SKIPPED | Directory Already Exist"
fi

# Generate Root CA

ls $workdir | grep ca > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $caDir 2> $log
fi

ls $workdir/ca/ | grep ca.key > /dev/null && ls $workdir/ca/ | grep ca.crt > /dev/null

# To do : serial belum tepat proses dibuatnya

if [ $(echo $?) != 0 ]; then
	openssl req -x509 -nodes -newkey rsa:2048 -keyout $caDir/ca.key -out $caDir/ca.crt -subj "/C=ID/ST=Jakarta/O=marimovpn/CN=ROOT CA" 2>> $log
	if [ $(echo $?) != 0 ]; then
		echo "Generating Root CA Certificate | FAILED "
		exit
	else
		echo "Generating Root CA Certificate | SUCCESS"
	fi
else
	echo 01 > $caDir/serial
	echo "Creating Root CA Certificate | SKIPPED | Certificate  Already Exist"
fi

