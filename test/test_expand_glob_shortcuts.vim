function! TestExpandGlobShortcuts(path)
  exe 'return <SNR>' . g:gripe_sid . '_expand_glob_shortcuts("' . a:path . '")'
endfunction

let g:gripe_use_glob_shortcuts = 1

let g:gripe_glob_shortcut_char = '@'
echo '--> @vim      == ' . TestExpandGlobShortcuts('@vim')
echo '--> @@vim     == ' . TestExpandGlobShortcuts('@@vim')
echo '--> @@.vim    == ' . TestExpandGlobShortcuts('@@.vim')
echo '--> @@[c,h]   == ' . TestExpandGlobShortcuts('@@[c,h]')
echo '--> @@.[c,h]  == ' . TestExpandGlobShortcuts('@@.[c,h]')
echo '--> @         == ' . TestExpandGlobShortcuts('@')
echo '--> @@        == ' . TestExpandGlobShortcuts('@@')

let g:gripe_glob_shortcut_char = '+'
echo '--> +vim      == ' . TestExpandGlobShortcuts('+vim')
echo '--> ++vim     == ' . TestExpandGlobShortcuts('++vim')
echo '--> ++.vim    == ' . TestExpandGlobShortcuts('++.vim')
echo '--> ++[c,h]   == ' . TestExpandGlobShortcuts('++[c,h]')
echo '--> ++.[c,h]  == ' . TestExpandGlobShortcuts('++.[c,h]')
echo '--> +         == ' . TestExpandGlobShortcuts('+')
echo '--> ++        == ' . TestExpandGlobShortcuts('++')
