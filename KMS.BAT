#!/bin/bash

#====================================================
#	System Request: Debian/Ubuntu/Mint/CentOS/Redhat/Fedora
#====================================================

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
STAT=2

do_debian(){
apt-get install gcc git make -y
rm -rf /usr/local/kms
mkdir /usr/local/kms
cd /usr/local/kms
git clone https://github.com/Wind4/vlmcsd.git
cd vlmcsd
make
cd bin
mv vlmcsd /usr/local/kms/kms
cd /usr/local/kms/
rm -rf ./vlmcsd/
mv kms vlmcsd
echo "KMS installed successfully "
echo ""
}


do_centos(){
yum install gcc git make -y
rm -rf /usr/local/kms
mkdir /usr/local/kms
cd /usr/local/kms
git clone https://github.com/Wind4/vlmcsd.git
cd vlmcsd
make
cd bin
mv vlmcsd /usr/local/kms/kms
cd /usr/local/kms/
rm -rf ./vlmcsd/
mv kms vlmcsd
echo "KMS installed successfully"
}

# Detecting KMS operation status
check_running(){
PID=`ps -ef | grep -v grep | grep -i "vlmcsd" | awk '{print $2}'`
		if [ ! -z $PID ]; then
		STAT=0
	else
		STAT=1
	fi
}

# Restart KMS service
do_restart(){
	check_running
	if [ $STAT = 0 ]; then
		echo "KMS service is running and restarting ..."
		kill $PID
	elif [ $STAT = 1 ]; then
		echo "KMS service is not running and is starting..."
	fi
	/usr/local/kms/vlmcsd
	check_running
	if [ $STAT = 0 ]; then
		local_ip=`curl -4 ip.sb`
		echo "KMS service started successfully"
	elif [ $STAT = 1 ]; then
		echo "KMS service startup failed"
	fi
}

# Stop KMS service
do_stop(){
	check_running
	if [ $STAT = 0 ]; then
			echo "Stopping KMS service ..."
		kill $PID
		check_running
		if [ $STAT = 0 ]; then
			echo "Stopping KMS service failed"
		elif [ $STAT = 1 ]; then
			echo "Stop KMS service successfully"
			fi
		elif [ $STAT = 1 ]; then
				echo "KMS service is not running. Cancel the operation."
		fi
}

# Check whether the KMS service is running
do_status(){
	check_running
	if [ $STAT = 0 ]; then
				echo "KMS service is running"
		elif [ $STAT = 1 ]; then
				echo "KMS service is not running"
		fi
}

# Start KMS service
do_start(){
	check_running
	if [ $STAT = 0 ]; then
				echo "KMS service is running Cancel operation"
		exit 0;
		elif [ $STAT = 1 ]; then
				echo "Starting KMS service ..."
	/usr/local/kms/vlmcsd
	fi
		check_running
		if [ $STAT = 0 ]; then
				local_ip=`curl -4 ip.sb`
				echo "KMS service started successfully"
		elif [ $STAT = 1 ]; then
				echo "KMS service failed to start"
		fi
}

# Add auto-start service at boot
do_auto(){
	echo "/usr/local/kms/vlmcsd" >> /etc/rc.local
	chmod +x /etc/rc.local
	echo "Added KMS service to start automatically at boot"
}

# Uninstall KMS service
do_uninstall(){
	do_stop
	rm -rf /usr/local/kms
	sed -i '/vlmcsd/'d /etc/rc.local
	echo "KMS service has been uninstalled"
}

# Script menu
case "$1" in
	debian|centos|start|stop|auto|restart|status|uninstall)
	do_$1
	;;
	*)
	echo "Missing parameters: debian | centos | start | stop | auto | restart | status | uninstall "
	;;
esac

