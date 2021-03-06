#!/sbin/busybox2 sh

(
	PROFILE=$(cat /data/.shift/.active.profile);
	. /data/.shift/${PROFILE}.profile;

	if [ "$cron_db_optimizing" == "on" ]; then
		for i in $(find /data -iname "*.db"); do
			/system/xbin/sqlite3 $i 'VACUUM;' > /dev/null;
			/system/xbin/sqlite3 $i 'REINDEX;' > /dev/null;
		done;

		date +%H:%M-%D-%Z > /data/crontab/cron-db-optimizing;
		echo "Done! DB Optimized" >> /data/crontab/cron-db-optimizing;
		sync;
	fi;
)&
