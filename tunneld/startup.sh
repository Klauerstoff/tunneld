# startup.sh
# make sure errors stop execution
set -e
# start the cronjob
crond -b -l 8 &
# Tail the log file
tail -f /tmp/cron.log