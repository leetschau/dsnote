#!/bin/bash

NOTE_REPO="$HOME/.donno/repo"
GITBOOK_REPO="$HOME/docs/tech-blog"
SUMMARY=$GITBOOK_REPO/SUMMARY.md
cp $NOTE_REPO/t*.md $GITBOOK_REPO

cat <<EOF > $SUMMARY
# Summary

EOF

notes=$(ls -t $NOTE_REPO/t*.md)
for note in $notes; do
  title=$(sed -n 1p $note | cut -c8- | sed 's/\"/`/g')
  fn=$(basename $note)
  echo "* [$title]($fn)" >> $SUMMARY
done

echo "cd $GITBOOK_REPO
Commit changes and push to remote"
