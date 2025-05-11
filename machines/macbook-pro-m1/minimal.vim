set nocompatible
set noswapfile
set nobackup
set nowritebackup
set autoread
set autowriteall
set updatetime=50
set hidden

augroup Scratchpad
  autocmd!
  autocmd TextChanged,TextChangedI * silent! wall
augroup END
