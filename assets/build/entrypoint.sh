#!/bin/sh

set -e

CONFIG_FILE="${CONFIG_FILE:-/app/config/wg0.conf}"

if [ $# -eq 0 ]; then
	if [ ! -f "$CONFIG_FILE" ]; then
		echo "Error: config file not found at $CONFIG_FILE"
		exit 1
	fi

	if ! grep -q "^Table" "$CONFIG_FILE"; then
		echo "Warning: 'Table' option not found in $CONFIG_FILE. Adding 'Table = off' to the config."
		echo "Table = off" >>"$CONFIG_FILE"
	fi

	wg-quick up "$CONFIG_FILE" || {
		echo "Error: Failed to bring up WireGuard interface using $CONFIG_FILE"
		exit 1
	}

	ip route add default dev wg0 2>/dev/null || echo "Default route already exists"
elif [ "$1" = "wgcf" ]; then
	shift
	if [ -x "/app/wgcf" ]; then
		exec /app/wgcf "$@"
	else
		echo "Error: /app/wgcf is not executable or not found"
		exit 1
	fi
else
	exec "$@"
fi
