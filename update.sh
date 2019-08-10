#!/bin/bash
echo "UPDATING..."

LOGS="$(git pull|grep firmware.exe)"
echo "LOGS: [""$LOGS""]"
[ -z "$LOGS" ] || (echo "rebooting" && sleep 30 && sudo reboot)

sleep 2
LOGS="$(git pull|grep firmware.exe)"
echo "LOGS: [""$LOGS""]"
[ -z "$LOGS" ] || (echo "rebooting" && sleep 30 && sudo reboot)
