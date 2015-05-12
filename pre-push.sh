#!/bin/sh

remote="$1"
url="$2"
root=$(git rev-parse --show-toplevel)
git rev-list HEAD --count > $root/stats/commits
git log -1 --pretty=%B > $root/stats/lastmessage
	
scp teggers@teggers.eu:public_html/index.php ./
sed -i "s/<p>Number of times compiled: <b>[0-9]\+<\/b><\/p>/<p>Number of times compiled: <b>$(cat $root/stats/compiled)<\/b><\/p>/g" index.php
sed -i "s/<p>Number of pages: <b>[0-9]\+<\/b><\/p>/<p>Number of pages: <b>$(cat $root/stats/pages)<\/b><\/p>/g" index.php
sed -i "s/<p>Number of words: <b>[0-9]\+<\/b><\/p>/<p>Number of words: <b>$(cat $root/stats/words)<\/b><\/p>/g" index.php
sed -i "s/<p>Number of figures: <b>[0-9]\+<\/b><\/p>/<p>Number of figures: <b>$(cat $root/stats/figures)<\/b><\/p>/g" index.php
sed -i "s/<p>Number of git commits: <b>[0-9]\+<\/b><\/p>/<p>Number of git commits: <b>$(cat $root/stats/commits)<\/b><\/p>/g" index.php
sed -i "s/<p>Last commit message: <b>.\+<\/b><\/p>/<p>Last commit message: <b>$(cat $root/stats/lastmessage)<\/b><\/p>/g" index.php
scp index.php teggers@teggers.eu:public_html/
rm ./index.php

exit 0
