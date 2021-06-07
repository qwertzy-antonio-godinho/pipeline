#!/usr/bin/env bash

set -e

[[ -f $DEVPISERVER_SERVERDIR/.serverversion ]] || initialize=yes

shutdown() {
    devpi-server --stop
    kill -SIGTERM $TAIL_PID
}

trap shutdown SIGTERM SIGINT

if [ -f $DEVPISERVER_SERVERDIR/.serverversion ]; then
  echo "Using existing directory..."
else
  echo "Initializing DevPi for the first time..."
  devpi-init
fi

devpi-server \
--host 0.0.0.0 \
--port $DEVPI_PORT \
--theme $DEVPI_THEME \
--debug &

DEVPI_PID=$!

sleep 10

nginx

devpi use http://localhost:$DEVPI_PORT
if [[ $initialize = yes ]]; then
  devpi login root --password=""
  devpi user -m root password="${DEVPI_ROOT_PASSWORD}"
  devpi user -c "${DEVPI_USER_NAME}" password="${DEVPI_USER_PASSWORD}"
  devpi login "${DEVPI_USER_NAME}" --password="${DEVPI_USER_PASSWORD}" 
  devpi index -c "${DEVPI_INDEX}"/"${DEVPI_REPO}" bases=root/pypi volatile=True acl_upload="${DEVPI_USER_NAME}"
  #devpi index -y -c public pypi_whitelist='*'
fi
devpi login root --password="${DEVPI_ROOT_PASSWORD}"

tail -f /var/log/nginx/access.log &
tail -f /var/log/nginx/error.log &
TAIL_PID=$!

wait $TAIL_PID

wait $DEVPI_PID
EXIT_STATUS=$?
