#!/bin/sh

percentage="$(cat /sys/class/power_supply/BAT?/capacity)"
level="$(cat /sys/class/power_supply/BAT?/capacity_level)"
status="$(cat /sys/class/power_supply/BAT?/status)"

echo "${percentage} ${level} ${status}"
