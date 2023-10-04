# Colors
white='\033[0m'
red='\033[1;31m'

# Status
failed="${red}FAILED${white}"
success="SUCCESS"
skipped="SKIPPED"

# working directory
workdir=/etc/ssl/marimocerts
log=./log/marimo.log
caDir=$workdir/ca

# Checking Certificate Directory

ls /etc/ssl/marimocerts/ > /dev/null

if [ $(echo $?) != 0 ]; then
	mkdir $workdir 2>> $log
	if [ $(echo $?) != 0 ]; then
		echo -e "Creating Certificate Directory			| $failed "
		exit
	else
		echo -e "Creating Certificate Directory			| $success "
	fi
else
	echo -e "Creating Certificate Directory			| $skipped | Directory Already Exist"
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
		openssl req -x509 -nodes -newkey rsa:2048 -keyout $caDir/ca.key -out $caDir/ca.crt -subj "/C=ID/ST=Jakarta/O=marimovpn/CN=ROOT CA" 2>> $log && echo "01" | tee $caDir/serial > /dev/null
	if [ $(echo $?) != 0 ]; then
		echo -e "Generating Root CA Certificate			| $failed"
		exit
	else
		echo -e "Generating Root CA Certificate			| $success"
	fi
else
	echo -e "Creating Root CA Certificate			| $skipped | Certificate  Already Exist"
fi

