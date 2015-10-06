#!/sbin/busybox sh

ROOT_RW()
{
mount -o remount,rw /;
}
ROOT_RW;

# fix owners on critical folders
chown -R root:root /tmp;
chown -R root:root /res;
chown -R root:root /sbin;
chown -R root:root /lib;

# oom and mem perm fix
chmod 666 /sys/module/lowmemorykiller/parameters/cost;
chmod 666 /sys/module/lowmemorykiller/parameters/adj;

# allow user and admin to use all free mem.
echo 0 > /proc/sys/vm/user_reserve_kbytes;
echo 8192 > /proc/sys/vm/admin_reserve_kbytes;

mkdir -p /data/.shift
chmod 777 /data/.shift
mkdir -p /data/media/0/shift/backup_synapse
mkdir -p /data/media/0/shift/screenshots
chmod 775 /data/media/0/shift -R
chmod 755 /res/uci.sh
chmod 755 /res/synapse/actions/*

. /res/customconfig/customconfig-helper

ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.shift/.ccxmlsum`" ];
then
  rm -f /data/.shift/*.profile
  echo ${ccxmlsum} > /data/.shift/.ccxmlsum
fi
[ ! -f /data/.shift/default.profile ] && cp /res/customconfig/default.profile /data/.shift

read_defaults
read_config

# Fix Synapse database permissions.
if [ -d /data/data/com.af.synapse ]; then
	SYNAPSE_OWNER=`ls -ld /data/data/com.af.synapse | awk 'NR==1 {print $3}'`
	if [ ! -z $SYNAPSE_OWNER ]; then
		/sbin/busybox chown "$SYNAPSE_OWNER"."$SYNAPSE_OWNER" /data/data/com.af.synapse/databases -R
	fi;
	chmod 771 /data/data/com.af.synapse/databases
	chmod 660 /data/data/com.af.synapse/databases/actionValueStore
	chmod 600 /data/data/com.af.synapse/databases/actionValueStore-journal
fi;

/sbin/busybox mount -t rootfs -o remount,rw rootfs
uci
/sbin/busybox mount -t rootfs -o remount,ro rootfs

# Apps and ROOT Install
/sbin/busybox sh /sbin/ext/install.sh;

if [ "$logger" == "on" ];then
insmod /lib/modules/logger.ko
fi

# start CROND by tree root, so it's will not be terminated.
$BB sh /res/crontab_service/service.sh;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod -R 06755 /sbin/ext/;
	$BB chmod 06755 /sbin/busybox;
	$BB chmod 06755 /system/xbin/busybox;
}
CRITICAL_PERM_FIX;

# disable debugging on some modules
if [ "$logger" == "off" ];then
  rm -rf /dev/log
  echo 0 > /sys/module/kernel/parameters/initcall_debug
  echo 0 > /sys/module/lowmemorykiller/parameters/debug_level
  echo 0 > /sys/module/earlysuspend/parameters/debug_mask
fi

if [ "$cifs" == "on" ];then
insmod /system/lib/modules/cifs.ko
fi

# copy cron files
$BB cp -a /res/crontab/ /data/
if [ ! -e /data/crontab/custom_jobs ]; then
	$BB touch /data/crontab/custom_jobs;
	$BB chmod 777 /data/crontab/custom_jobs;
fi;

# EFS backup
(
/sbin/busybox sh /sbin/ext/efs-backup.sh
) &

# apply STweaks defaults
/res/uci.sh apply
