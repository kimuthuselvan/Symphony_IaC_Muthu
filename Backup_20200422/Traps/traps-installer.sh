#! /bin/bash

CAT=/bin/cat
DIRNAME=/usr/bin/dirname

MYDIR="$(cd -- "$($DIRNAME -- "$0")" && pwd)"

traps_version=$($CAT "$MYDIR/.version")
installer_path="$MYDIR/traps_linux-$traps_version.sh"
servers_xml_path="$MYDIR/Servers.xml"

echo -e "\e[1;34mStarting Traps for Linux installer with the following params:\e[0m"
echo "traps_version: $traps_version"
echo "installer_path: $installer_path"
echo "servers_xml_path: $servers_xml_path"
if [ $# -gt 0 ]; then
    echo "additional params: $@"
fi
echo

"$installer_path" -- --servers-xml "$servers_xml_path" "$@"

