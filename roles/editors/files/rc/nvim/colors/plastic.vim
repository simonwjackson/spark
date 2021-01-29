colorscheme plastic
let s:foreground = [ '#a9b2c3', 235 ]
let s:background = [ '#1D2026', 235 ]
let s:yellow = [ '#e5c07b', 180 ]
let s:purple = [ '#af98e6', 170 ]
let s:red = [ '#e06c75', 204 ]
let s:blue = [ '#61afef', 39 ]
let s:green = [ '#98c379', 114 ]
let s:grey = [ '#abb2bf', 59 ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}
let s:p.normal.left = [ [ s:foreground, s:background ], [ s:green, s:background ] ]
let s:p.normal.right = [ [ s:purple, s:background ], [ s:green, s:background ] ]
let s:p.inactive.right = [ [ s:grey, s:background ], [ s:grey, s:background ] ]
let s:p.inactive.left =  [ [ s:grey, s:background ], [ s:grey, s:background ] ]
let s:p.insert.left = [ [ s:background, s:green ], [ s:green, s:background ] ]
let s:p.replace.left = [ [ s:red, s:background ], [ s:red, s:background ] ]
let s:p.visual.left = [ [ s:background, s:purple ], [ s:purple, s:background ] ]
let s:p.normal.middle = [ [ s:foreground, s:background ] ]
let s:p.inactive.middle = [ [ s:grey, s:background ] ]
let s:p.tabline.left = [ [ s:blue, s:grey ] ]
let s:p.tabline.tabsel = [ [ s:foreground, s:background ] ]
let s:p.tabline.middle = [ [ s:foreground, s:background ] ]
let s:p.tabline.right = copy(s:p.normal.right)
let s:p.normal.error = [ [ s:background, s:red ] ]
let s:p.normal.warning = [ [ s:background, s:yellow ] ]

let g:lightline#colorscheme#plastic#palette = lightline#colorscheme#flatten(s:p)
let g:lightline.colorscheme = 'plastic'

" LightlineReload

silent! hi! EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg
hi CursorLine           guibg=#2D3239 guifg=None

" Dim
highlight def Dim guifg=#333c4a

" Highlight Yanks
highlight HighlightedyankRegion ctermbg=235 ctermfg=170

hi VertSplit            guibg=#1D2026 guifg=#1D2026
hi StatusLine           guibg=bg guifg=#888888
hi StatusLineNC         guibg=bg guifg=#555555
hi foldColumn           guibg=bg

" Coverage
hi CoverageUncovered    guifg=#5A5242

" GitGutter
highlight GitGutterAdd ctermbg=None guibg=none ctermfg=114 guifg=#556c49
highlight GitGutterChange ctermbg=None guibg=none ctermfg=180 guifg=#56b6c2
highlight GitGutterDelete ctermbg=None guibg=none ctermfg=204 guifg=#e06c75
highlight GitGutterChangeDelete ctermbg=None guibg=none ctermfg=180 guifg=#e5c07b

" Coc
" function! CocNvimHighlight()
" hi! CocErrorHighlight   ctermfg=Green  guifg=#00ff00
" hi! CocWarningHighlight ctermfg=Green  guifg=#00ff00
" hi! CocInfoHighlight    ctermfg=Green  guifg=#00ff00
" hi! CocHintHighlight    ctermfg=Green  guifg=#00ff00
" hi! CocErrorLine        ctermfg=Green  guifg=#00ff00
" hi! CocWarningLine      ctermfg=Green  guifg=#00ff00
" hi! CocInfoLine         ctermfg=Green  guifg=#00ff00
" hi! CocHintLine         ctermfg=Green  guifg=#00ff00
hi! ALEErrorSign    ctermbg=None guifg=#e06c75
hi!                 link CocErrorSign ALEErrorSign
hi! ALEWarningSign  ctermbg=None guifg=#e5c07b
hi!                 link CocWarningSign ALEWarningSign
hi! AleInfoSign     ctermbg=None guifg=#61afef
hi!                 link AleInfoSign CocInfoSign

highlight CocHighlightText  guibg=#111111 ctermbg=223
" endfunction

" autocmd VimEnter function CocNvimHighlight()

" command! LightlineReload call LightlineReload()
"
" function! LightlineReload()
"   call lightline#init()
"   call lightline#colorscheme()
"   call lightline#update()
" endfunction 
