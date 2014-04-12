This is a note-taking utility inspired by Evernote. It's written in bash. So, of course, runs in Linux command line. I use it everyday, and I believe every Linux coder should use it :)

# Installation

    git clone https://leechau@bitbucket.org/leechau/dsnote.git
    cd dsnote
    chmod 755 donshell.sh

Then open your ~/.bashrc or ~/.zshrc, add this line:

    alias dn='/path/to/dsnote/donshell.sh'

# Usage

* Show help:

    dn

* Create note:

    dn a

* List note:

    dn l

* Edit note:

    dn e [n]

* View note:

    dn v [n]

* Search note:

    dn s key1 key2

* Complex Search:

    dn sc -t key1 key2 ... -g key1 key2

* Delete note:

    dn del [n]

* Backup notes:

    dn b

* Restore notes:

    dn r

# Some notes

The note editor is vim, so you can add some plugins to make it more powerful for editing and viewing. For example, if you write notes in markdown syntax, you can add markdown plugin for vim.

