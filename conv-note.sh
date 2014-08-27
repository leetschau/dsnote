#!/bin/bash

show_help() {
    cat <<-EOF
usage: ./conv-note.sh [all | help]
Convert dsnote to octopress notes. Then you can use the following commands to publish your notes:

cd $OCTOPRESS_HOME
rake generate
rake preview
rake deploy

If you add option "all", then all dsnotes will be generated. Without it, only notes newer than newest .markdown file in $OCTO_BLOG_HOME/source/_posts will be generated.
EOF
}

REPO="$HOME/.donno/repo"
OCTO_BLOG_HOME="$HOME/apps/octopress/source/_posts"

if [[ $# -eq 0 ]]; then
    newnotes=$(find $REPO -newer $(ls -t $OCTO_BLOG_HOME/*.markdown|head -1) -type f | egrep 't[0-9]+.mkd')
elif [[ $1 == "all" ]]; then
    newnotes=$(ls $REPO/t*.mkd)
else
    show_help
    exit 1
fi

for afile in $newnotes; do
    title=$(sed -n 1p $afile | cut -c8- | sed 's/\"/`/g')
    tags=$(sed -n 2p $afile | cut -c7- | sed 's/;/,/g')
    created=$(sed -n 4p $afile | cut -c10-)
    oldfn=$(basename $afile)
    newdate="20${oldfn:1:2}-${oldfn:3:2}-${oldfn:5:2} ${oldfn:7:2}:${oldfn:9:2}:${oldfn:11:2}"
    newfn="$OCTO_BLOG_HOME/20${oldfn:1:2}-${oldfn:3:2}-${oldfn:5:2}-${oldfn:7:6}.markdown"
    cat <<ENDOFFILE > $newfn
---
layout: post
title: "$title"
date: $newdate +0800
comments: true
categories: [$tags]
---

$(sed -n '8,$p' $afile)
ENDOFFILE
    echo Publish note: $title to octopress
done
