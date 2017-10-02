This is a note-taking utility inspired by Evernote.
It's written in bash (for Linux) and PowerShell (for Windows).
For all terminal fans :)

# Installation

First clone this repo into your $APP_BASE folder.

For Linux, check if the file 'donshell.sh' has executable permission.
If not, run `chmod 755 $APP_BASE/dsnote/donshell.sh`.
Then open ~/.bashrc or ~/.zshrc, add a alias:
`alias dn=$APP_BASE/dsnote/donshell.sh'`.

For Windows, install editor and viewer *vim* with:
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
