#!/bin/bash

LocalRepo="/tmp/blogRepo"
BlogHome="$LocalRepo/blogs"
Readme="$LocalRepo/README.md"

source $(dirname "$0")/myconfig

rm -rf $LocalRepo
git clone $BlogURL $LocalRepo
cp $PubBlogPath $BlogHome

for afile in $BlogHome/*; do
  modified=$(awk -F ': ' 'FNR==5 {print $2}' $afile)  # 5 is MODIFIED_LINE_NO
  touch -d "$modified" $afile
done

cat << EOF > $Readme
Welcome to Leo's tech blog :)

# Table of Contents

EOF
for fullname in $(ls -t $BlogHome/*); do
  created=$(sed -n 4p $fullname | cut -d' ' -f2)
  title=$(awk -F ': ' 'FNR==1 {print $2}' $fullname)
  tags=$(awk -F ': ' 'FNR==2 {print $2}' $fullname)
  filename=$(basename $fullname)
  rec="+ [$title](blogs/$filename) $created $tags"
  echo $rec >> $Readme
  sed -i "1 c # $title" $fullname
  sed -i "3,5 d" $fullname
done
cd $LocalRepo
git add -A
git commit -m 'update blogs'
git push
