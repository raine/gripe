" Vim global plugin providing minimal coloured grep
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.2
" Description:	Uses builtin vimgrep, showing results in the location-list
" 		and colouring the search term with Search highlight group.
" Last Change:	2014-10-01
" License:	Vim License (see :help license)
" Location:	plugin/gripe.vim
" Website:	https://github.com/dahu/gripe
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

if !exists('g:gripe_use_glob_shortcuts')
  let g:gripe_use_glob_shortcuts = 0
endif

if !exists('g:gripe_glob_shortcut_char')
  let g:gripe_glob_shortcut_char = '@'
endif

" Private Functions: {{{1

function! s:escape(search_term)
  return '/' . escape(a:search_term, '/') . '/'
endfunction

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
  if delim !~ '[a-zA-Z_^]'
    let search_term = matchstr(a:args, '^' . delim . '.\{-}\\\@<!' . delim)
    let path = strpart(a:args, len(search_term))
    if path =~ '^\s*\.\?\s*$'
      let path = '**/*'
    endif
  else
    let args = split(a:args, '\\\@<! ')
    let path = args[-1]
    if len(args) == 1
      let path = '**/*'
      let search_term = s:escape(args[0])
    elseif path == '.'
      let path = '**/*'
      let search_term = s:escape(join(args[0:-2]))
    else
      if path =~ '[@*?\[\]]'
        let search_term = s:escape(join(args[0:-2]))
      else
        let path = '**/*'
        let search_term = s:escape(join(args[0:-1]))
      endif
    endif
  endif

  try
    silent exe 'lvimgrep ' . search_term . 'j ' . s:expand_glob_shortcuts(path)
    lopen
    let search_term = substitute(search_term[1:-2], '^^', '', '')
    call matchadd("Search", search_term)
  catch /^Vim\%((\a\+)\)\=:E480/
    redraw  " necessary to prevent internal redraw erasing these messages
    echohl Error
    echomsg 'Gripe: ' . search_term . ' not found in ' . path
    echohl None
  endtry
endfunction

" Maps: {{{1
nnoremap <Plug>GripeWord :call Gripe(expand("<cword>"))<CR>

if !hasmapto('<Plug>GripeWord')
  nmap <unique><silent> <leader>gw <Plug>GripeWord
endif

" Commands: {{{1
command! -bar -nargs=+ -complete=file Gripe call Gripe(<q-args>)

" Teardown: {{{1
" reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
