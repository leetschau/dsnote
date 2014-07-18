DonnoHome=".donno"
BaseDir="${HOME}/$DonnoHome"
Repo="${BaseDir}/repo"
LastResult="${BaseDir}/.last-result"
LastSync="${BaseDir}/.last-sync"
Trash="${BaseDir}/trash/"

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
    echo No. Updated, Title, Tags, Notebook, Created, Sync?
    if test $# -eq 1; then
        listno=$1
    elif test $# -eq 0; then
        listno=5
    else
        echo Bad command format. dn l [N].
        exit 1
    fi
    ls -t ${Repo}/*.mkd|head -${listno} > ${LastResult}
    printnotes
}

function simplesearch() {
    if [[ $# = 0 ]]; then
        echo Bad command format: no search keywords found.
        exit 1
    fi
    # grep -i: ignore case; -l: only print file name
    res=$(grep -i -l $1 $Repo/*.mkd)
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
    res=$(ls -t $Repo/*.mkd)
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
    if [[ $# = 1 && $1 != 'c' ]]; then
        echo "Unkown parameters. Synopsis: dn b [c]"
        exit 1
    fi

    cd ~
    fn=notes$(date +"%y-%m-%d-%H.%M.%S").bz2
    touch $LastSync
    tar jcf $fn $DonnoHome/
    cd -
    if [[ ! -f ./$fn ]]; then
        mv ~/$fn .
    fi
    if [[ $# == 1 && $1 == 'c' ]]; then
        script_dir=$(dirname $0)
        if [[ -x $script_dir/../Dropbox-Uploader/dropbox_uploader.sh ]]; then
            $script_dir/../Dropbox-Uploader/dropbox_uploader.sh upload $fn backup/
        else
            echo "Please install Dropbox-Uploader for this function."
            exit 1
        fi
    fi
}

function restorenotes() {
    if [[ $# == 1 && $1 == 'c' ]]; then
        script_dir=$(dirname $0)
        if [[ -x $script_dir/../Dropbox-Uploader/dropbox_uploader.sh ]]; then
            newest=$($script_dir/../Dropbox-Uploader/dropbox_uploader.sh list backup | awk 'END{print $3}')
            $script_dir/../Dropbox-Uploader/dropbox_uploader.sh download backup/$newest
        else
            echo "Please install Dropbox-Uploader for this function."
            exit 1
        fi
    fi
    src=$(ls -t *.bz2|head -1)
    if [ -z $src ]; then
        echo There is no bz2 file under current folder.
        exit 1
    fi
    read -p "Restore from $src? All local notes lost. (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^y$ ]]; then
        rm -rf ~/.donno
        tar jxf $src -C ~/
    else
        echo User cancelled.
    fi
    listnotes
}

function editnote() {
    if test $# -eq 1; then
        vim $(sed -n $1p ${LastResult})
    elif test $# -eq 0; then
        vim $(sed -n 1p ${LastResult})
    else
        echo Bad command format. dn e [N].
        exit 1
    fi
    listnotes
}

function viewnote() {
    if test $# -eq 1; then
        vim -R $(sed -n $1p ${LastResult})
    elif test $# -eq 0; then
        vim -R $(sed -n 1p ${LastResult})
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

------

EOF
    fi
    vim $TempNote
    wc=$(awk FNR==1 $TempNote | wc -w)
    notebook=$(awk -F ': ' 'FNR==3 {print $2}' $TempNote)
    if [[ ${#notebook} -ne 1 ]]; then
        echo '"notebook" property must be specified with only ONE character, use "dn a" to edit notebook again'
        exit 1
    fi
    fn=$notebook$(date +"%y%m%d%H%M%S").mkd
    if [[ $wc -gt 1 && -n $notebook ]]; then
        mv $TempNote $Repo/$fn
    else
        echo Adding note cancelled: blank title or notebook.
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
