#!/bin/bash

REPO="/home/chad/.donno/repo"
OCTO_BLOG_HOME="/home/chad/apps/octopress/source/_posts"

for afile in $(find $REPO -newer $(ls -t $OCTO_BLOG_HOME/*.markdown|head -1) -type f | egrep 't[0-9]+.mkd'); do
    title=$(sed -n 1p $afile | cut -c8-)
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
