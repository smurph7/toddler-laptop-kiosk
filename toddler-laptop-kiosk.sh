#!/bin/sh
echo -ne '\033c\033]0;Toddler Laptop Kiosk\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/builds/toddler-laptop-kiosk.x86_64" "$@"
