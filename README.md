# Vim Arduino

This script allows you to compile and deploy Arduino (*.pde) sketches
directly from Vim.

## Install

The plugin should be organized in a manner that works well with
pathogen. I personally use [janus][janus] to manage my MacVim setup so
adding this line to my `~/.janus.rake` file does the trick:

```
vim_plugin_task "vim-arduino", "https://github.com/tclem/vim-arduino.git"
```

## Usage

You must have a pde (Arduino sketch) open in the current buffer.

`<Leader>ac` - Compile the current sketch.

`<Leader>ad` - Compile and deploy the current sketch.

`<Leader>as` - Open a serial port in `screen`.


The default key mapping can be turned off by doing this in your `.vimrc`:

```
let g:vim_arduino_map_keys = 0
```

## Requirements

You must have the [Arduino][arduino] IDE installed. Currently only
Version 0022 is supported.

[arduino]: http://arduino.cc/en/Main/Software
[janus]: https://github.com/carlhuda/janus
