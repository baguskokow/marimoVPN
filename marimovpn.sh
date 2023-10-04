workdir=/etc/ssl/marimocerts
log=./log/marimo.log
caDir=$workdir/ca

# Checking Certificate Directory

ls /etc/ssl/marimocerts/ 2> /dev/null
if [ $(echo $?) != 0 ]; then
#	echo -e "Step 1 = Creating Certificate Directory"
	mkdir $workdir 2>> $log
	if [ $(echo $?) != 0 ]; then
		echo "Step 1 = Creating Certificate Directory | FAILED "
	else
		echo "Step 1 = Creating Certificate Directory | SUCCESS "
	fi
else
	echo "Step 1 = Creating Certificate Directory | SKIPPED | Directory Already Exist"
fi

## Generate Root CA
#
#mkdir $caDir 2>> $log
#openssl req -x509 -nodes -newkey rsa:2048 -keyout $caDir/ca.key -out $caDir/ca.crt -subj "/C=ID/ST=Jakarta/O=marimovpn/CN=ROOT CA" 2>> $log
#
#if [ $(echo $?) != 0 ]; then
#	echo "Can't Generate Root CA Certificate, Please check the log!"
#else
#	echo "Root CA Certificate has been generated"
#fi
