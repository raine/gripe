function! TestExpandGlobShortcuts(path)
  exe 'return <SNR>' . g:grope_sid . '_expand_glob_shortcuts("' . a:path . '")'
endfunction

let g:grope_use_glob_shortcuts = 1

let g:grope_glob_shortcut_char = '@'
echo '--> @vim      == ' . TestExpandGlobShortcuts('@vim')
echo '--> @@vim     == ' . TestExpandGlobShortcuts('@@vim')
echo '--> @@.vim    == ' . TestExpandGlobShortcuts('@@.vim')
echo '--> @@[c,h]   == ' . TestExpandGlobShortcuts('@@[c,h]')
echo '--> @@.[c,h]  == ' . TestExpandGlobShortcuts('@@.[c,h]')
echo '--> @         == ' . TestExpandGlobShortcuts('@')
echo '--> @@        == ' . TestExpandGlobShortcuts('@@')

let g:grope_glob_shortcut_char = '+'
echo '--> +vim      == ' . TestExpandGlobShortcuts('+vim')
echo '--> ++vim     == ' . TestExpandGlobShortcuts('++vim')
echo '--> ++.vim    == ' . TestExpandGlobShortcuts('++.vim')
echo '--> ++[c,h]   == ' . TestExpandGlobShortcuts('++[c,h]')
echo '--> ++.[c,h]  == ' . TestExpandGlobShortcuts('++.[c,h]')
echo '--> +         == ' . TestExpandGlobShortcuts('+')
echo '--> ++        == ' . TestExpandGlobShortcuts('++')
