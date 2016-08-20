#!/bin/bash

version="v4.20-9608-rtm-2016.04.17"

initfile="vpnserver"

echo "Select Architecture"
echo
echo " 1. Arm EABI (32bit)"
echo " 2. Intel x86 (32bit)"
echo " 3. Intel x64/AMD64 (64bit)"
echo
echo "Please choose architecture: "
read tmp
echo

if test "$tmp" = "3"
then
	arch="64bit_-_Intel_x64_or_AMD64"
	arch2="x64-64bit"
	echo "Selected : 1 " $arch
elif test "$tmp" = "2"
then
	arch="32bit_-_Intel_x86"
	arch2="x86-32bit"
	echo "Selected : 2 " $arch
elif test "$tmp" = "1"
then
	arch="32bit_-_ARM_EABI"
	arch2="arm_eabi-32bit"
	echo "Selected : 3 " $arch
else #default if non selected
	arch="32bit_-_Intel_x86"
	arch2="x86-32bit"
	echo "Selected : 2 " $arch
fi

file="softether-vpnserver-"$version"-linux-"$arch2".tar.gz"
link="http://www.softether-download.com/files/softether/"$version"-tree/Linux/SoftEther_VPN_Server/"$arch"/"$file

if [ ! -s "$file" ]||[ ! -r "$file" ];then
	#remove and redownload empty or unreadable file
	rm -f "$link"
	wget "$link"
elif [ ! -f "file" ];then
	#download if not exist
	wget "$file"
fi

if [ -f "$file" ];then
	tar xzf "$file"
	dir=$(pwd)
	echo "current dir " $dir
	cd vpnserver
	dir=$(pwd)
	echo "changed to dir " $dir
else
	echo "Archive not found. Please rerun this script or check permission."
	break
fi

apt-get update && apt-get upgrade
apt-get install build-essential -y
	
make
cd ..
mv vpnserver /usr/local
dir=$(pwd)
echo "current dir " $dir
cd /usr/local/vpnserver/
dir=$(pwd)
echo "changed to dir " $dir
chmod 600 *
chmod 700 vpnserver
chmod 700 vpncmd

mkdir /var/lock/subsys

touch /etc/init.d/"$initfile"
#need to cat two time to pass varible($initfile) value inside
cat > /etc/init.d/"$initfile" <<EOF
#!/bin/sh
# chkconfig: 2345 99 01
# description: SoftEther VPN Server
DAEMON=/usr/local/vpnserver/$initfile
LOCK=/var/lock/subsys/$initfile
EOF

cat >> /etc/init.d/"$initfile" <<'EOF'
test -x $DAEMON || exit 0
case "$1" in
start)
$DAEMON start
touch $LOCK
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac
exit 0
EOF

chmod 755 /etc/init.d/"$initfile"
update-rc.d "$initfile" defaults
/etc/init.d/"$initfile" start
	
echo "DONE"

