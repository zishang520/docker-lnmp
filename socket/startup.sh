#!/bin/sh

LOCAL_IP=$(hostname -i | grep -oE '((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])\.){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])' | head -n 1)
export INTRANET_IP="${INTRANET_IP:-127.0.0.1}"

# Start crond in background
crond -l 2 -b

# Start socket in foreground
php "${APP_CODE_PATH_CONTAINER:-/www}/start.php" start