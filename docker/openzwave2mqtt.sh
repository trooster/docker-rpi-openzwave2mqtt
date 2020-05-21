#!/usr/bin/env bash
[ -z "$DEBUG" ] || set -x
set -eo pipefail
shopt -s nullglob

DEBUG=${DEBUG:-info}
CONFIGDIR="${CONFIGDIR:-/config}"
CONFIGFILE="${CONFIGFILE:-$CONFIGDIR/options.xml}"
CRASHDIR="${CRASHDIR:-$CONFIGDIR/crashes/}"
ARGS=(--config-dir "${CONFIGDIR}" --user-dir "${CONFIGDIR}")


# Usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD.txt" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="${1}"
    local def="${2:-}"

    local fvar="${CONFIGDIR}/${var}.txt"
    local val="${def}"

    if [ -n "${!var:-}" ] && [ -r "${fvar}" ]
    then
        echo "* Warning: both ${var} and ${fvar} are set, file '${var}' takes priority"
    fi
    if [ -r "${fvar}" ]
    then
        val=$(< "${fvar}")
    elif [ -n "${!var:-}" ]
    then
        val="${!var}"
    fi
    export "${var}"="${val}"
}


generate_network_key() {
    # The network encryption key size is 128-bit which is essentially 16 decimal
    # 16 hexadecimal values

    cat /dev/urandom | tr -dc '0-9A-F' | fold -w 32 | head -n 1 | sed -e 's/\(..\)/0x\1, /g' -e 's/, $//'
}


# Environment variables
LOG_LEVEL="${LOG_LEVEL:-$DEBUG}"
DEVICE="${DEVICE:-/dev/ttyUSB0}"
INSTANCE="${INSTANCE:-1}"
STOP_ON_FAILURE="${STOP_ON_FAILURE:-true}"
MQTT_SERVER="${MQTT_SERVER:-127.0.0.1}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_USER="${MQTT_USER:-}"
MQTT_PASS="${MQTT_PASS:-}"
# ZWave network key changing requires repairing of all devices
file_env 'NETWORK_KEY' "$(generate_network_key)"
# if configfile is empty, generate one
if [ ! -s "${CONFIGFILE}" ]
then
    echo "${NETWORK_KEY}" > "${CONFIGDIR}/NETWORK_KEY.txt"
fi
# OZW_AUTH_KEY

if [ ! -c "${DEVICE}" ]
then
    echo "Device '${DEVICE}' does not exist or is not a character device!"
    exit 128
fi
OZW_ARGS+=(--serial-port "$DEVICE")
[ "${STOP_ON_FAILURE}" == "true" ] && OZW_ARGS+=(--stop-on-failure)
OZW_ARGS+=(--mqtt-instance "${INSTANCE}")
OZW_ARGS+=(--mqtt-server "${MQTT_SERVER}")
OZW_ARGS+=(--mqtt-port "${MQTT_PORT}")
[ -z "${MQTT_USER}" ] || OZW_ARGS+=(--mqtt-username "$MQTT_USER")
mkdir -p ${CRASHDIR}

# If command starts with an option, prepend ozwdaemon
if [ "${1:0:1}" = '-' ]
then
    set -- ozwdaemon "$@"
fi
if [ "${1}" == "ozwdaemon" ]
then
    export MQTT_PASSWORD="${MQTT_PASS}"
    export BP_DB_PATH="${CRASHDIR}"
    export OZW_NETWORK_KEY="${NETWORK_KEY}"
    case ${LOG_LEVEL} in
      info|INFO)
        export QT_LOGGING_RULES="*.debug=false;ozw.library.debug=true"
        ;;
      debug|DEBUG)
        export QT_LOGGING_RULES="*.debug=true"
        ;;
      *)
        export QT_LOGGING_RULES="*.debug=false"
        ;;
    esac
    exec "$@" "${OZW_ARGS[@]}"
else
    exec "$@"
fi

