# vim-stackoverflow

A vim plugin that allows you to search Stack Overflow right from vim.

Requires vim compiled with python support. You can check this by running ``vim
--version | grep +python`` - if something is returned, you're good to go.

##Installation

Use your plugin manager of choice.

- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `git clone https://github.com/mickaobrien/vim-stackoverflow ~/.vim/bundle/vim-stackoverflow`
- [Vundle](https://github.com/gmarik/vundle)
  - Add `Plugin 'mickaobrien/vim-stackoverflow'` to .vimrc
  - Run `:PluginInstall`
- [NeoBundle](https://github.com/Shougo/neobundle.vim)
  - Add `NeoBundle 'https://github.com/mickaobrien/vim-stackoverflow'` to .vimrc
  - Run `:NeoBundleInstall`
- [vim-plug](https://github.com/junegunn/vim-plug)
  - Add `Plug 'https://github.com/mickaobrien/vim-stackoverflow'` to .vimrc
  - Run `:PlugInstall`

##Usage
The plugin adds one command, ``:StackOverflow``. It can be called as follows

``:StackOverflow 'query'``

This will open a buffer with relevant Stack Overflow questions. ``o`` will
toggle the questions open and closed.
