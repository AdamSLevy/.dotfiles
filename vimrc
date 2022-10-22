" an example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Dec 17
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.

set nocompatible              " be iMproved, required
filetype off                  " required

filetype plugin indent on    " required

if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" IMPORTANT: Uncomment one of the following lines to force
" using 256 colors (or 88 colors) if your terminal supports it,
" but does not automatically use 256 colors by default.
set t_Co=256
"set t_Co=88
let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : '' }
" set default colorscheme
set relativenumber
set number
set cursorline
set viminfo='1000,f1,<500

" set onmi complete
set nocp
filetype plugin on

runtime! ftplugin/man.vim

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" set all tabs to be spaces
set expandtab
set smarttab
set tabstop=8
set softtabstop=0
set shiftwidth=8

" set fold method to be based on markers
set foldmethod=manual

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=90		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set ignorecase          " case insensitive search
set smartcase           " case insensitive search if no capital letter exists.

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

set undofile
set undodir=~/.cache/vim/undo
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo

set backupdir=~/.cache/vim/backup
set dir=~/.cache/vim/swap

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Wildmenu
" This sets file completion to be more bash-like
if has("wildmenu")
    set wildignore+=*.a,*.o
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
    set wildignore+=.DS_Store,.git,.hg,.svn
    set wildignore+=*~,*.swp,*.tmp
    set wildmenu
    set wildmode=longest,list
endif

"inoremap <Tab> <C-X><C-F>

function! s:disable_coc_for_type()
        let l:filesuffix_blacklist = ['md', 'txt']
	if index(l:filesuffix_blacklist, expand('%:e')) != -1
		let b:coc_enabled = 0
	endif
endfunction

command! Vimrc :tabedit ~/.vimrc

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 80 characters.
  autocmd FileType text setlocal textwidth=80

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

    fun! <SID>StripTrailingWhitespaces()
        let l = line(".")
        let c = col(".")
        " let _s=@/
        keeppatterns %s/\s\{2,}$/ /e
        call cursor(l, c)
        " let @/=_s
    endfun

    fun! <SID>CurrentLineIsComment() 
            let state = synIDattr(synIDtrans(synID(line("."), col("."), 0)), "name")
            echom "state: " . state
            return state == "Comment"
    endfun
    fun! <SID>StripTrailingWhitespacesFromCurrentLineIfComment()
        let isComment = <SID>CurrentLineIsComment() 
        if !isComment
                echom "not a comment: " . isComment
                return
        endif
        echom "is a comment: " . isComment
        let l = line(".")
        let c = col(".")
        " let _s=@/
        keeppatterns .s/\s\+$//e
        call cursor(l, c)
        " let @/=_s
    endfun

    autocmd FileType bash,html,javascript,css,ruby setlocal shiftwidth=2 tabstop=2
    autocmd FileType bash,html,javascript,css,ruby syntax on
    autocmd FileType go,c,cpp setlocal shiftwidth=8 tabstop=8 expandtab

    autocmd FileType go nnoremap <leader>b :GoBuild<CR>
    autocmd FileType go nnoremap <leader>e :GoRun<CR>
    autocmd FileType go nnoremap <leader>t :GoTest<CR>
    autocmd FileType go nnoremap <leader>r :GoRename<CR>

    autocmd FileType rust nnoremap <leader>b :CBuild<CR>
    autocmd FileType rust nnoremap <leader>r :RustRun<CR>
    autocmd FileType rust nnoremap <leader>t :RustTest<CR>
    autocmd FileType markdown set wrap linebreak textwidth=0 wrapmargin=0 formatoptions+=ta
    autocmd FileType sh set formatoptions-=t
    autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
    autocmd BufReadPost *.html syntax on
    autocmd BufRead *.md set ft=markdown
    autocmd BufRead,BufNewFile * call s:disable_coc_for_type()

    autocmd BufWritePost ~/.vimrc :source <afile>

    "autocmd InsertLeavePre * :call <SID>StripTrailingWhitespacesFromCurrentLineIfComment()

    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

    autocmd FileType go let b:go_fmt_options = {
      \ 'goimports': '-local ' .
      \ trim(system('{cd '. shellescape(expand('%:h')) .' && go list -m;}')),
      \ }

    autocmd BufNewFile,BufRead *.tftpl :set filetype=tf
else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

set whichwrap=b,s,<,>,[,]

map <F1> <esc>
imap <F1> <esc>

set cinoptions+=b1
set cinkeys+="0=break"
set spelllang=en
set spellfile=$HOME/.vimrc/spell/en.utf-8.add

nnoremap <F2> :TagbarToggle<CR>
nnoremap <F3> :CtrlPMixed<CR>
nnoremap <F4> :NERDTreeToggle<CR>

" Prevent the middle mouse button from pasting the clipboard. Important for
" using ThinkPad TrackPoint keyboards.
map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>
map <2-MiddleMouse> <Nop>
imap <2-MiddleMouse> <Nop>
map <3-MiddleMouse> <Nop>
imap <3-MiddleMouse> <Nop>
map <4-MiddleMouse> <Nop>
imap <4-MiddleMouse> <Nop>

set belloff=all

" Scroll lines ahead of cursor, a large number keeps the cursor centered on
" the screen.
"set scrolloff=40
" We're now using drzel/vim-scrolloff-fraction
let g:scrolloff_fraction = 0.30


" " Keep unnamed/default register synced with the system clipboard
" set clipboard^=unnamed,unnamedplus

" Use leader key to use the system clipboard for copy/paste
" Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_

nnoremap <leader>b :

" Paste from clipboard
nnoremap <leader>p "+p
vnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>P "+P

" Improve scrolling latency by limiting syntax highlighting region
set lazyredraw
set synmaxcol=200
syntax sync minlines=95

" " Improve PageUp and PageDown scrolling to retain cursor position
" map <silent> <PageUp> 1000<C-U>
" map <silent> <PageDown> 1000<C-D>
" imap <silent> <PageUp> <C-O>1000<C-U>
" imap <silent> <PageDown> <C-O>1000<C-D>

" " Improve scroll wheel scrolling
" map <ScrollWheelUp> H5k
" map <ScrollWheelDown> L5j

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'tpope/vim-sensible', { 'tag': '*' }
Plug 'tpope/vim-fugitive', { 'tag': '*' }
Plug 'tpope/vim-commentary', { 'tag': '*' }
Plug 'tpope/vim-git', { 'tag': '*' }
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-eunuch', { 'tag': '*' }
Plug 'tpope/vim-repeat', { 'tag': '*' }
Plug 'tpope/vim-surround', { 'tag': '*' }

Plug 'junegunn/seoul256.vim'
Plug 'fatih/vim-go', { 'tag': 'v1.25', 'do': ':GoUpdateBinaries' }
"Plug 'tabnine/YouCompleteMe'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'github/copilot.vim'

Plug 'preservim/nerdtree', { 'tag': '*' }
Plug 'ctrlpvim/ctrlp.vim', { 'tag': '*' }

Plug 'rust-lang/rust.vim'

Plug 'preservim/tagbar'

Plug 'vim-airline/vim-airline', { 'tag': '*' }
Plug 'vim-airline/vim-airline-themes'

Plug 'airblade/vim-gitgutter'

Plug 'WolfgangMehner/bash-support', { 'tag': '*' }

Plug 'z0mbix/vim-shfmt', { 'for': 'sh' }

Plug 'Yggdroot/indentLine'
Plug 'pedrohdz/vim-yaml-folds'

Plug 'djoshea/vim-autoread'

Plug 'tomlion/vim-solidity'

Plug 'hashivim/vim-terraform'

Plug 'drzel/vim-scrolloff-fraction'

Plug 'mrded/vim-github-codeowners', {'do': 'npm install'}

Plug 'habamax/vim-asciidoctor'

Plug 'dkarter/bullets.vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

colorscheme seoul256

if filereadable(".lvimrc")
    source .lvimrc
endif

" vim-terraform
let g:terraform_fmt_on_save=1
let g:terraform_align=1

" vim-shfmt
let g:shfmt_fmt_on_save = 1
let g:shfmt_extra_args = '-i 2 -ci'

let g:indentLine_char_list = ['·', ':', '⋮', '⁞','|', '¦', '┆', '┊']

let g:go_build_tags = 'integration,developer'

let g:rustfmt_autosave = 1
let g:rust_clip_command = 'pbcopy'


" recommended by airblade/vim-gitgutter
set updatetime=300 " ms

" " COC settings
" " Always show the signcolumn, otherwise it would shift the text each time
" " diagnostics appear/become resolved.
" set signcolumn=yes

" " Use tab for trigger completion with characters ahead and navigate.
" " NOTE: There's always complete item selected by default, you may want to enable
" " no select by `"suggest.noselect": true` in your configuration file.
" " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" " other plugin before putting this into your config.
" inoremap <silent><expr> <TAB>
"       \ coc#pum#visible() ? coc#pum#next(1) :
"       \ CheckBackspace() ? "\<Tab>" :
"       \ coc#refresh()
" inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" " Make <CR> to accept selected completion item or notify coc.nvim to format
" " <C-g>u breaks current undo, please make your own choice.
" inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                               \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" function! CheckBackspace() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~# '\s'
" endfunction

" " Use <c-space> to trigger completion.
" if has('nvim')
"   inoremap <silent><expr> <c-space> coc#refresh()
" else
"   inoremap <silent><expr> <c-@> coc#refresh()
" endif

" " Use `[g` and `]g` to navigate diagnostics
" " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
" nmap <silent> [g <Plug>(coc-diagnostic-prev)
" nmap <silent> ]g <Plug>(coc-diagnostic-next)

" " GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

" " Use K to show documentation in preview window.
" nnoremap <silent> K :call ShowDocumentation()<CR>

" function! ShowDocumentation()
"   if CocAction('hasProvider', 'hover')
"     call CocActionAsync('doHover')
"   else
"     call feedkeys('K', 'in')
"   endif
" endfunction

" " Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

" " Symbol renaming.
" nmap <leader>rn <Plug>(coc-rename)

" " Formatting selected code.
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

" augroup mygroup
"   autocmd!
"   " Setup formatexpr specified filetype(s).
"   autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
"   " Update signature help on jump placeholder.
"   autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
" augroup end

" " Applying codeAction to the selected region.
" " Example: `<leader>aap` for current paragraph
" xmap <leader>a  <Plug>(coc-codeaction-selected)
" nmap <leader>a  <Plug>(coc-codeaction-selected)

" " Remap keys for applying codeAction to the current buffer.
" nmap <leader>ac  <Plug>(coc-codeaction)
" " Apply AutoFix to problem on the current line.
" nmap <leader>qf  <Plug>(coc-fix-current)

" " Run the Code Lens action on the current line.
" nmap <leader>cl  <Plug>(coc-codelens-action)

" " Map function and class text objects
" " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
" xmap if <Plug>(coc-funcobj-i)
" omap if <Plug>(coc-funcobj-i)
" xmap af <Plug>(coc-funcobj-a)
" omap af <Plug>(coc-funcobj-a)
" xmap ic <Plug>(coc-classobj-i)
" omap ic <Plug>(coc-classobj-i)
" xmap ac <Plug>(coc-classobj-a)
" omap ac <Plug>(coc-classobj-a)

" " Remap <C-f> and <C-b> for scroll float windows/popups.
" if has('nvim-0.4.0') || has('patch-8.2.0750')
"   nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"   nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
"   inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
"   inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
"   vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"   vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
" endif

" " Use CTRL-S for selections ranges.
" " Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" " Add `:Format` command to format current buffer.
" command! -nargs=0 Format :call CocActionAsync('format')

" " Add `:Fold` command to fold current buffer.
" command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" " Add `:OR` command for organize imports of the current buffer.
" command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" " Add (Neo)Vim's native statusline support.
" " NOTE: Please see `:h coc-status` for integrations with external plugins that
" " provide custom statusline: lightline.vim, vim-airline.
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" " Mappings for CoCList
" " Show all diagnostics.
" nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" " Manage extensions.
" nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" " Show commands.
" nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" " Find symbol of current document.
" nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" " Search workspace symbols.
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" " Do default action for next item.
" nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" " Do default action for previous item.
" nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" " Resume latest coc list.
" nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" "" end COC settings

" Git shortcuts
" copy a link to github.
nnoremap <leader>g :GBrowse!<CR>
vnoremap <leader>g :GBrowse!<CR>

"yaml linting
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'never'

" codeowners in airline
function! AirlineInit()
  let g:airline_section_z = airline#section#create(['codeowners'])
endfunction

autocmd User AirlineAfterInit call AirlineInit()

" c	Auto-wrap comments using 'textwidth', inserting the current comment
"       leader automatically.
set formatoptions+=c

" r	Automatically insert the current comment leader after hitting
" 	<Enter> in Insert mode.
set formatoptions+=r

" q	Allow formatting of comments with "gq".
" 	Note that formatting will not change blank lines or lines containing
" 	only the comment leader.  A new paragraph starts after such a line,
" 	or when the comment leader changes.
set formatoptions+=q

" w	Trailing white space indicates a paragraph continues in the next line.
" 	A line that ends in a non-white character ends a paragraph.
" set formatoptions+=w

" a	Automatic formatting of paragraphs.  Every time text is inserted or
" 	deleted the paragraph will be reformatted.  See |auto-format|.
" 	When the 'c' flag is present this only happens for recognized
" 	comments.
"set formatoptions+=a

" n	When formatting text, recognize numbered lists.  This actually uses
" 	the 'formatlistpat' option, thus any kind of list can be used.  The
" 	indent of the text after the number is used for the next line.  The
" 	default is to find a number, optionally followed by '.', ':', ')',
" 	']' or '}'.  Note that 'autoindent' must be set too.  Doesn't work
" 	well together with "2".
" 	Example: >
" 		1. the first item
" 		   wraps
" 		2. the second item
set formatoptions+=n

" 1	Don't break a line after a one-letter word.  It's broken before it
" 	instead (if possible).
set formatoptions+=1

" j	Where it makes sense, remove a comment leader when joining lines.  For
" 	example, joining:
" 		int i;   // the index ~
" 		         // in the list ~
" 	Becomes:
" 		int i;   // the index in the list ~
set formatoptions+=j
