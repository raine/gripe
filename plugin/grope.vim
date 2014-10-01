" Vim global plugin providing minimal coloured grep
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Description:	Uses builtin vimgrep, showing results in the location-list
" 		and colouring the search term with Search highlight group.
" Last Change:	2014-10-01
" License:	Vim License (see :help license)
" Location:	plugin/grope.vim
" Website:	https://github.com/dahu/grope
"
" See grope.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help grope

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

let g:loaded_grope = 1

" Private Functions: {{{1
function! s:escape(search_term)
  return '/' . escape(a:search_term, '/') . '/'
endfunction

" Public Interface: {{{1
function! Grope(args)
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
      if path =~ '[*?\[\]]'
        let search_term = s:escape(join(args[0:-2]))
      else
        let path = '**/*'
        let search_term = s:escape(join(args[0:-1]))
      endif
    endif
  endif

  try
    silent exe 'lvimgrep ' . search_term . 'j ' . path
    lopen
    call matchadd("Search", search_term[1:-2])
  catch /^Vim\%((\a\+)\)\=:E480/
    redraw  " necessary to prevent internal redraw erasing these messages
    echohl Error
    echomsg 'Grope: ' . search_term . ' not found in ' . path
    echohl None
  endtry
endfunction

" Maps: {{{1
nnoremap <Plug>GropeWord :call Grope(expand("<cword>"))<CR>

if !hasmapto('<Plug>GropeWord')
  nmap <unique><silent> <leader>gw <Plug>GropeWord
endif

" Commands: {{{1
command! -bar -nargs=+ -complete=file Grope call Grope(<q-args>)

" Teardown: {{{1
" reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
