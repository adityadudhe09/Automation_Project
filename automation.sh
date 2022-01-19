
#Update of the package details and the package list
sudo apt update -y

#Let's initialize the variables
name="aditya"
s3_bucketname="upgrad-adityadudhe"


# Check if the Apache2 package is installed
dpkg --get-selections | grep apache2

if [ $? -eq 0 ]
then
    echo "Apache2 packages are already installed."
else
    echo "Installing Apache2 packages!!!!!"
    sudo apt install apache2 -y
fi
echo


# Let's ensure if the apache2 service is running
echo "Status of apache2 service:"
sudo systemctl status apache2 | grep Active

if [[ $? -eq 0 ]]; then
	echo "Apache2 service is Active and Running"
else
	echo "Let's start the Apache2 service!!!"
		sudo service apache2 start

		if [[ $? -eq 0 ]]; then
			echo "Apache2 service started successfully"
		fi
fi
echo

# Let's ensure if apache2 service is enabled 
echo "Check if apache2 service is enabled: "
sudo systemctl is-enabled apache2 | grep enabled

if [[ $? -eq 0 ]]; then
	echo "Apache2 service is already enabled."

else
	echo "Enabling the Apache2 service."
	sudo service apache2 enable
fi
echo

# Creating a tar archive of apache2 access logs and error logs
timestamp=$(date '+%d%m%Y-%H%M%S')

tar -cvf /tmp/${name}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

# Let's check if AWS Command Line Interface (CLI) is installed in the system
echo "AWS Command Line Interface (CLI) status:"
dpkg --get-selections | grep awscli

if [[ $? -eq 0 ]]; then
	echo "AWS Command Line Interface (CLI) is already installed."
else
	echo "Let's install the AWS Command Line Interface (CLI)!!!"
	sudo apt install awscli
fi
echo

# Let's copy the archive to the s3 bucket
aws s3 \
cp /tmp/${name}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
echo

#Check if the inventory.html file exist
inventoryFile=/var/www/html/inventory.html
fsize=$(ls -lh /tmp/$filename | grep httpd | awk '{print $5}' )
logType="httpd-logs"
if ! test -f "$inventoryFile"; then

        echo "Inventory File is missing!!! Let's create Inventory file..."
        touch ${inventoryFile}
        
         printf "Log Type               Time Stamp            Type          Size          \n" >> ${inventoryFile}
         echo 
         printf "$logType          $timestamp          tar            $fsize           \n" >> ${inventoryFile}
fi
	echo "Logs are updated in Inventory file..."
	printf "$logType          $timestamp          tar            $fsize           \n" >> ${inventoryFile}


#Creating a cron job file for everyday run

cronjob=/etc/cron.d/automation

if [ ! -f $cronjob ]; then
	touch /etc/cron.d/automation
	printf "* * * * * root /root/Automation_Project/auotmation.sh" >> ${cronjob}
fi
