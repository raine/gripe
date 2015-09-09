" Vim global plugin providing minimal coloured grep
" Maintainer:   Barry Arthur <barry.arthur@gmail.com>
" Version:      0.2
" Description:  Uses builtin vimgrep, showing results in the location-list
"               and colouring the search term with Search highlight group.
" Last Change:  2014-10-01
" License:      Vim License (see :help license)
" Location:     plugin/gripe.vim
" Website:      https://github.com/dahu/gripe
"
" See gripe.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help gripe

let g:gripe_version = '0.2'

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun
let gripe_sid = s:SID()

" Global Options: {{{1

if !exists('g:gripe_external_tool')
  let g:gripe_external_tool = ''
endif

if !exists('g:gripe_ag_format')
  let g:gripe_ag_format = '%f:%l:%c:%m'
endif

if !exists('g:gripe_ag_cmd')
  let g:gripe_ag_cmd = 'ag --nobreak --nocolor --column --nogroup --noheading'
endif

if !exists('g:gripe_use_glob_shortcuts')
  let g:gripe_use_glob_shortcuts = 0
endif

if !exists('g:gripe_glob_shortcut_char')
  let g:gripe_glob_shortcut_char = '@'
endif

" Private Functions: {{{1

function! s:expand_glob_shortcuts(path)
  return g:gripe_use_glob_shortcuts ?
        \ substitute(a:path,
        \   '\w\@<!' . g:gripe_glob_shortcut_char
        \   . '\(' . g:gripe_glob_shortcut_char . '\)\?\(\w\)\?',
        \   '\="*"
        \   . (len(submatch(1)) > 0 ? "*/*" : "")
        \   . (len(submatch(2)) > 0 ? "." . submatch(2) : "")
        \   ', 'g')
        \ : a:path
endfunction

" Public Interface: {{{1

function! Gripe(args)
  let delim = a:args[0]
  let path = ''
  if delim !~ '[a-zA-Z_^\\]'
    let search_term = matchstr(a:args, '^' . delim . '.\{-}\\\@<!' . delim)
    let path = strpart(a:args, len(search_term))
    if path =~ '^\s*\.\?\s*$'
      let path = '**'
    endif
  else
    let args = split(a:args, '\\\@<! ')
    let path = args[-1]
    if len(args) == 1
      let path = '**'
      let search_term = args[0]
    elseif path == '.'
      let path = '**'
      let search_term = join(args[0:-2])
    else
      if path =~ '[@*?\[\]]'
        let search_term = join(args[0:-2])
      else
        let path = '**'
        let search_term = join(args[0:-1])
      endif
    endif
  endif

  let success = GripeTool(search_term, s:expand_glob_shortcuts(path))
  if success != 0
    lopen
    let search_term = substitute(search_term, '^^', '', '')
    " :lgrep replaces % with current buffer, so a search for   \\% or \\\% (for lvimgrep)
    " needs to be repaired for use with matchadd()
    let search_term = substitute(search_term, '\\\+%', '%', 'g')
    call matchadd("Search", search_term)
  else
    redraw  " necessary to prevent internal redraw erasing these messages
    echohl Error
    echomsg 'Gripe: ' . search_term . ' not found in ' . path
    echohl None
  endif
endfunction

function! GripeTool(search_term, path)
  let success = 0
  if g:gripe_external_tool == ''
    " use internal lvimgrep
    try
      if a:search_term =~ '^/.*/$'
        let search_term = a:search_term[2:-2]
      else
        let search_term = a:search_term
      endif
      silent exe 'lvimgrep /' . escape(search_term, '/') . '/j ' . a:path
    catch /^Vim\%((\a\+)\)\=:E480/
      " success = 0
    endtry
    let success = 1
  else
    " only external tool supported for now is ag
    let grepprg    = &grepprg
    let grepformat = &grepformat
    try
      let &grepprg    = g:gripe_ag_cmd
      let &grepformat = g:gripe_ag_format
      silent! exe 'lgrep! ' . shellescape(escape(a:search_term, '|')) . ' ' . escape(a:path, '|')
      redraw!
      let success = 1
    finally
      let &grepprg    = grepprg
      let &grepformat = grepformat
    endtry
  endif
  return success
endfunction

function! GripeVisual()
  let sel_save   = &selection
  let &selection = "inclusive"
  let reg_save   = @@
  silent exe "normal! gvy"
  call Gripe(@@)
  let &selection = sel_save
  let @@         = reg_save
endfunction

" Maps: {{{1
nnoremap <Plug>GripeWord   :call Gripe(expand("<cword>"))<CR>
xnoremap <Plug>GripeVisual :<c-u>call GripeVisual()<CR>

if !hasmapto('<Plug>GripeWord')
  nmap <unique><silent> <leader>gw <Plug>GripeWord
endif

if !hasmapto('<Plug>GripeVisual')
  xmap <unique><silent> <leader>gw <Plug>GripeVisual
endif

" Commands: {{{1
command! -bar -nargs=+ -complete=file Gripe call Gripe(<q-args>)

" Teardown: {{{1
" reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
