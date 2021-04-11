export XDG_CONFIG_HOME="$HOME/.config/vimrcs/text"

DonnoHome=".dsnote"
BaseDir="${HOME}/$DonnoHome"
Repo="${BaseDir}/repo"
LastResult="${BaseDir}/.last-result"
LastSync="${BaseDir}/.last-sync"
Trash="${BaseDir}/trash/"
EDITOR="nvim"
MODIFIED_LINE_NO=5  # the line number of "Modified: 2017-09-27 11:14:55"

function printnotes() {
    note_no=1
    for fullname in $(cat ${LastResult}); do
        updated=$(date -r ${fullname} +"%y-%m-%d %H:%M:%S")
        title=$(awk -F ': ' 'FNR==1 {print $2}' ${fullname})
        tags=$(awk -F ': ' 'FNR==2 {print $2}' ${fullname})
        filename=$(basename $fullname)
        note_type=$(echo ${filename:0:1} | tr '[:lower:]' '[:upper:]')
        created=$(awk -F ': ' 'FNR==4 {print $2}' ${fullname})
        backuped=""
        test $fullname -nt $LastSync && backuped="+"
        echo ${note_no}. [${updated}] ${title} [${tags}] [Type:${note_type}] ${created} $backuped
        note_no=$((${note_no} + 1))
    done
}

function listnotes() {
    if [ ! -d $Repo ]; then
        echo "There is no notes, restore with 'dn r' and try again"
        exit 1
    fi
    echo No. Updated, Title, Tags, Notebook, Created, Sync?
    if test $# -eq 1; then
        listno=$1
    elif test $# -eq 0; then
        listno=5
    else
        echo Bad command format. dn l [N].
        exit 1
    fi
    ls -t ${Repo}/*.md|head -${listno} > ${LastResult}
    printnotes
}

function simplesearch() {
    if [[ $# = 0 ]]; then
        echo Bad command format: no search keywords found.
        exit 1
    fi
    # grep -i: ignore case; -l: only print file name
    res=$(grep -i -l $1 $Repo/*.md)
    if [[ -z $res ]]; then
        echo Nothing match.
        exit 0
    fi
    shift
    for word in $@; do
        res=$(grep -i -l $word $res)
        if [[ -z $res ]]; then
            break
        fi
    done
    if [[ -z $res ]]; then
        echo Nothing match.
    else
        ls -t $res > $LastResult
        printnotes
    fi
}

function complexsearch() {
    if [[ $# = 0 ]]; then
        echo Bad command format: no search keywords found.
        exit 1
    fi
    res=$(ls -t $Repo/*.md)
    for key in $@; do
        if [[ $key = "-c" ]]; then
            line=0
        elif [[ $key = "-t" ]]; then
            line=1
        elif [[ $key = "-g" ]]; then
            line=2
        elif [[ $key = "-b" ]]; then
            line=3
        else
            if [[ -z $line ]]; then
                echo Bad format: there is no -t\|g before keys
                exit 1
            fi
            if [[ line -eq 0 ]]; then
                res=$(grep -i -l $key $res)
            elif [[ line -eq 3 ]]; then
                res=$(awk "BEGIN{IGNORECASE=1} FNR==$line && /.*\s${key}.*/ {print FILENAME}" $res)
            else
                res=$(awk "BEGIN{IGNORECASE=1} FNR==$line && /.*${key}.*/ {print FILENAME}" $res)
            fi
        fi
    done 
    if [[ -z $res ]]; then
        echo Nothing match.
    else
        ls -t $res > $LastResult
        printnotes
    fi
}

function backupnotes() {
    if [[ $# == 1 && $1 != 'c' ]]; then
        echo "Unkown parameters. Synopsis: dn b [c]"
        exit 1
    fi

    cd $Repo
    git add -A
    git commit -m 'update notes'
    if [[ $# == 1 && $1 == 'c' ]]; then
        git push
    fi
    cd -
    touch $LastSync
}

function restorenotes() {
    if [ ! -d $Repo ]; then
        mkdir -p $BaseDir
        cd $BaseDir
        read -p 'Input note repo address (git@...): ' notesRepo
        git clone $notesRepo repo
    else
        cd $Repo
        git pull
    fi
    echo "notes repo pull over"
    for afile in $Repo/*; do
      modified=$(awk -F ': ' 'FNR==5 {print $2}' $afile)  # 5 is MODIFIED_LINE_NO
      echo modify LastModTime of file $afile to $modified
      touch -d "$modified" $afile
    done
    cd -
    touch $LastSync
    listnotes
}

function editnote() {
    if test $# -eq 1; then
        target=$(sed -n $1p ${LastResult})
    elif test $# -eq 0; then
        target=$(sed -n 1p ${LastResult})
    else
        echo Bad command format. dn e [N].
        exit 1
    fi
    $EDITOR $target

    updated=$(date -r $target +"%Y-%m-%d %H:%M:%S")
    sed -i "$MODIFIED_LINE_NO c Modified: $updated" $target

    notetype=$(awk -F ': ' 'FNR==3 {print $2}' $target)
    originName=$(basename $target)
    newname=$Repo/$notetype${originName:1}
    if [[ ! -f $newname ]]; then
        mv $target $newname
    fi
    listnotes
}

function viewnote() {
    if test $# -eq 1; then
        $EDITOR -R $(sed -n $1p ${LastResult})
    elif test $# -eq 0; then
        $EDITOR -R $(sed -n 1p ${LastResult})
    else
        echo Bad command format. dn v [N].
        exit 1
    fi
}

function addnote() {
    TempNote="newnote.tmp"
    created=$(date +"%Y-%m-%d %H:%M:%S")
    if [[ ! -f $TempNote ]]; then
        cat <<EOF > $TempNote
Title: 
Tags: 
Notebook [t/j/o/y/c]: 
Created: $created
Modified: $created

------

EOF
    fi
    $EDITOR $TempNote
    wc=$(awk FNR==1 $TempNote | wc -w)
    notetype=$(awk -F ': ' 'FNR==3 {print $2}' $TempNote)
    if [[ ${#notetype} -ne 1 ]]; then
        echo '"notetype" property must be specified with only ONE character, use "dn a" to edit notetype again'
        exit 1
    fi
    fn=$notetype$(date +"%y%m%d%H%M%S").md
    if [[ $wc -gt 1 && -n $notetype ]]; then
        mv $TempNote $Repo/$fn
    else
        echo Adding note cancelled: blank title or notetype.
        read -p "Delete the temp note? (y/n) " -n 1
        echo
        if [[ $REPLY =~ ^y$ ]]; then
            rm $TempNote
        fi
    fi
    listnotes
}

function delnote() {
    mkdir -p $Trash
    if test $# -eq 1; then
        mv $(sed -n $1p ${LastResult}) $Trash
    elif test $# -eq 0; then
        mv $(sed -n 1p ${LastResult}) $Trash
    else
        echo Bad command format. dn del [N].
        exit 1
    fi
    listnotes
}
