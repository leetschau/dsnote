#!/bin/bash

show_help() {
    cat <<-EOF
usage: dn command [options]
Donno is a personal CLI note-taking app.
Available command:
a           Add note
b [c]       Backup notes (to Cloud)
l [N]       List recent [N] modified notes, 5 by default
r [c]       Restore notes (from Cloud)
s [key1 key2 ...]
            Simple search
sc [-t titile1 title2 ...] [-g tag1 tag2 ...]
            Complex search
v [N]       View the note, the most recent modified by default
e [N]       Edit the note, the most recent modified by default
del         Delete the note
p           Publish technical notes to blogs on www.cnblogs.com
EOF
}

if test $# -eq 0; then
    show_help
    exit 1
fi

source ./notes.sh

case $1 in
    a) addnote;;
    b) shift
       backupnotes $@;;
    e) shift
       editnote $@;;
    l) shift
       listnotes $@;;
    r) shift
       restorenotes $@;;
    s) shift
       simplesearch $@;;
    sc) shift
       complexsearch $@;;
    v) shift
       viewnote $@;;
    y) shift
       syncnotes $@;;
    del) shift
       delnote $@;;
esac
