#!/usr/bin/env bash

## update_yourls.sh v0.01 (30th August 2025)
##  Updates YOURLS

if [ ! $# -eq 3 ]; then
	echo "Usage: $0 <domain> <old version> <new version>"
	echo
	echo "  eg. update_yourls.sh example.com 1.10.0 1.10.1"
	echo
	exit 1
fi

cd $HOME/$1
wget https://github.com/YOURLS/YOURLS/archive/refs/tags/$3.zip
unzip $3.zip
cp YOURLS-$2/.htaccess YOURLS-$3/
cp YOURLS-$2/user/config.php YOURLS-$3/user/
rm yourls
ln -s YOURLS-$3 yourls
rm $3.zip
echo
echo "Updated YOURLS v$2 to v$3 if you're lucky."

exit 0