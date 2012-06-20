" ============================================================================
" File:        vim-arduino.vim
" Description: vim plugin that enables arduino development
" Maintainer:  Tim Clem <timothy.clem@gmail.com>
" Last Change: Sep 26, 2011
" License:     Copyright (C) 2011 Tim Clem.
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
"
" ============================================================================
"
" NOTES
"
" Reference for how the Arduino IDE does compilation:
" https://github.com/arduino/Arduino/blob/0022/app/src/processing/app/debug/Compiler.java

let s:vim_arduino_version = '0.1.0'

" Load Once: {{{1
if exists("loaded_vim_arduino")
    finish
endif
let loaded_vim_arduino = 1

if !exists('g:vim_arduino_auto_open_serial')
  let g:vim_arduino_auto_open_serial = 0
endif

let s:helper_dir = expand("<sfile>:h")

" Private: Get the board to deploy to
"
" Boards can be defined in the first line of your pde file like this:
" // board: atmega238
"
" Returns the board defined on the first line of the pde file. Otherwise
" returns "uno".
function! s:ArduinoGetBoard()
  let l:line = getline(1)
  let l:i = match(l:line, "board:")
  if l:i < 0
    return "uno"
  endif

  let l:board = substitute(strpart(l:line, l:i + 6, strlen(l:line)), " ", "", "")
  return l:board
endfunction

" Private: Check to see if a file can be compiled by the Aruino IDE
"
" Returns the filename of the current buffer if it is a *.pde file. Otherwise
" empty string.
function! s:CheckFile()
  let l:f_name = expand('%:p')
  if l:f_name =~ '.pde$'
    return l:f_name
  elseif l:f_name =~ '.ino$'
    return l:f_name
  else
    echo "Only *.pde and *.ino files can be compilied. File" l:f_name "does not have a recognized extention."
    return ""
  endif
endfunction

function! s:PrintStatus(result)
  if a:result == 0
    echohl Statement | echomsg "Succeeded." | echohl None
  else
    echohl WarningMsg | echomsg "Failed." | echohl None
  endif
endfunction

" Private: Compile or deploy code
"
" Returns nothing.
function! s:InvokeArduinoCli(deploy)
  let l:flag = a:deploy ? "-d" : "-c"
  let l:f_name = s:CheckFile()
  if !empty(l:f_name)
    execute "w"
    if a:deploy
      echomsg "Compiling and deploying..." l:f_name
    else
      echomsg "Compiling..." l:f_name
    endif

    let l:board = s:ArduinoGetBoard()
    let l:command = s:helper_dir . "/vim-arduino " .
          \ l:flag . " " .
          \ "-b " . l:board . " " .
          \ shellescape(l:f_name)
    " echo l:command
    let l:result = system(l:command)
    call s:PrintStatus(v:shell_error)
    echo l:result
    call s:PrintStatus(v:shell_error)
  endif

endfunction

" Public: Compile the current pde file.
"
" Returns nothing.
function! ArduinoCompile()
  call s:InvokeArduinoCli(0)
endfunction

" Public: Compile and Deploy the current pde file.
"
" Returns nothing.
function! ArduinoDeploy()
  call s:InvokeArduinoCli(1)

  " optionally auto open a serial port
  if g:vim_arduino_auto_open_serial
    call ArduinoSerialMonitor()
  endif
endfunction

" Public: Monitor a serial port
"
" Returns nothing.
function! ArduinoSerialMonitor()
  echo system(s:helper_dir."/vim-arduino-serial")
endfunction

if !exists('g:vim_arduino_map_keys')
  let g:vim_arduino_map_keys = 1
endif

if g:vim_arduino_map_keys
  nnoremap <leader>ac :call ArduinoCompile()<CR>
  nnoremap <leader>ad :call ArduinoDeploy()<CR>
  nnoremap <leader>as :call ArduinoSerialMonitor()<CR>
endif
