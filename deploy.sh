#!/bin/bash
# Deployment script
release=$(date +"%Y-%m-%d %T")
default_version="dev"
default_server="dev"
html_file="index.html"

# Get OS platform
case "$(uname -s)" in
	Darwin)
		platform="Mac OS X"
		ostype=1
	;;
	FreeBSD)
		platform="FreeBSD"
		ostype=1
	;;
	Linux)
		platform="Linux"
		ostype=2
	;;
	CYGWIN*|MINGW32*|MSYS*)
		platform="MS Windows"
		ostype=2
	;;
	*)
		platform="Unknown"
		ostype=0
	;;
esac

clear
echo "╔═════════════════════════════════════════════════╗"
echo "║ ~ Deploy App ~                                  ║"
echo "╚═════════════════════════════════════════════════╝"
echo
echo "* Detected OS: $platform"
echo "* Release date: $release"
read -p "> Version name [‹┘ '$default_version']: " version
if [ "$version" = "" ]
then
	version=$default_version
fi

read -p "> Server name [‹┘ '$default_server']: " servername
if [ "$servername" = "" ]; then
	servername="$default_server"
	server=" -s $default_server"
else
	server=" -s $servername"
fi

read -p "> Rollback [‹┘ none; Yes; CommitHash]: " rollback
if [ "$rollback" = "" ]; then
	roll=""
elif [ "$rollback" = "y" ] || [ "$rollback" = "Y" ] || [ "$rollback" = "yes" ] || [ "$rollback" = "Yes" ]; then
	roll=" --rollback"
else
	roll=" --rollback=\"$rollback\""
fi

read -p "> Add meta name: version, release to file '$html_file' and/or press enter."

if [ -f "$html_file" ]; then
	if [ "$ostype" == 1 ]; then
		sed -i "" -E "s#(<[Mm][Ee][Tt][Aa][[:space:]]+[Nn][Aa][Mm][Ee][[:space:]]*=[[:space:]]*[\"'][Vv][Ee][Rr][Ss][Ii][Oo][Nn][\"'][[:space:]]+[Cc][Oo][Nn][Tt][Ee][Nn][Tt][[:space:]]*=[[:space:]]*[\"'])[[:print:]]{0,}([\"'][[:space:]]*/?>[[:space:]]*(</[Mm][Ee][Tt][Aa]>)?)#\1$version\2#g;s#(<[Mm][Ee][Tt][Aa][[:space:]]+[Nn][Aa][Mm][Ee][[:space:]]*=[[:space:]]*[\"'][Rr][Ee][Ll][Ee][Aa][Ss][Ee][\"'][[:space:]]+[Cc][Oo][Nn][Tt][Ee][Nn][Tt][[:space:]]*=[[:space:]]*[\"'])[[:print:]]{0,}([\"'][[:space:]]*/?>[[:space:]]*(</[Mm][Ee][Tt][Aa]>)?)#\1$release\2#g" "$html_file"
	else
		sed -i "" "s#\(<[Mm][Ee][Tt][Aa]\s\{1,\}[Nn][Aa][Mm][Ee]\s\{0,\}=\s\{0,\}[\"'][Vv][Ee][Rr][Ss][Ii][Oo][Nn][\"']\s\{1,\}[Cc][Oo][Nn][Tt][Ee][Nn][Tt]\s\{0,\}=\s\{0,\}[\"']\)[[:print:]]\{0,\}\([\"']\s\{0,\}/\?>\s\{0,\}\(</[Mm][Ee][Tt][Aa]>\)\?\)#\1$version\2#g;s#\(<[Mm][Ee][Tt][Aa]\s\{1,\}[Nn][Aa][Mm][Ee]\s\{0,\}=\s\{0,\}[\"'][Rr][Ee][Ll][Ee][Aa][Ss][Ee][\"']\s\{1,\}[Cc][Oo][Nn][Tt][Ee][Nn][Tt]\s\{0,\}=\s\{0,\}[\"']\)[[:print:]]\{0,\}\([\"']\s\{0,\}/\?>\s\{0,\}\(</[Mm][Ee][Tt][Aa]>\)\?\)#\1$release\2#g" "$html_file"
	fi
	echo "* Meta tags updated."
else
	echo "x File '$html_file' not found."
fi

if [ -f "phploy.phar" ]; then
	echo "* Starting PHPLoy for '$servername' server."
	echo
	php phploy.phar$server$roll
else
	echo "x PHPLoy not found."
	echo "x Command 'php phploy$server$roll' skipped."
	echo "* Exit."
	exit
fi