This is a note-taking utility inspired by Evernote.
It's written in bash (for Linux) and PowerShell (for Windows).
For all terminal fans :)

# Installation

First clone this repo into your $APP_BASE folder.

For Linux, check if the file 'donshell.sh' has executable permission.
If not, run `chmod 755 $APP_BASE/dsnote/donshell.sh`.
Then open ~/.bashrc or ~/.zshrc, add a alias:
`alias dn=$APP_BASE/dsnote/donshell.sh'`.

For Windows, you have 2 options:

## Based on bash

1. Install Git client from [Git website](https://git-scm.com/),
   so you got *git bash*, which is based on *mintty*;

1. Setup vim toolchain. In git bash:

    1. copy your *.vimrc* file to *~/.vimrc*;

    1. download file [plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim)
       to *~/.vim/autoload* according to [vim-plug](https://github.com/junegunn/vim-plug);

    1. in vim, run `:PlugInstall`

1. Clone [dsnote](https://github.com/leetschau/dsnote) into your app directory,
   for example: */d/apps*;

1. Setup command alias `dn`:  create file *~/.bashrc* or *~/.bash_profile* with
   content `alias dn='/d/apps/dsnote/donshell.sh'`;

## Based on Windows console

Install editor and viewer *vim* with:
```
choco install vim
```

Then define a command alias for your console emulator.
For example, with [cmder](http://cmder.net/),
add `dn=powershell -f C:\path\to\your\dsnote\donshell.ps1 $*` into file
*%CMDER_ROOT%\config\user-aliases.cmd*.

# Usage

* Show help: `dn`;

* Create a note: `dn a`;

* List notes: `dn l [note-num]` default is 5;

* Edit note: `dn e [note-no]`;

* View note: `dn v [note-no]`;

* Search note: `dn s key1 key2 ...`;

* Complex Search: `dn sc -t key1 key2 ... -g key1 key2... `;

* Delete note: `dn del [note-no]`;

* Backup notes to local repo: `dn b`;

* Backup notes to remote repo: `dn b c`;

* Restore notes from remote repo: `dn r`

# Publish tech blogs

Modify the values in file *myconfig* and run `./pub-to-github.sh`.

# Some notes

The default note editor is vim,
you can add plugins to make it convenient for editing and viewing.
For example, if you write notes in markdown syntax, add markdown plugin for vim.
