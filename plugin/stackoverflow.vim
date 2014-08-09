if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

if exists('g:loaded_stackoverflow') || &cp
    finish
endif
let g:loaded_stackoverflow = 1

command! -nargs=1 StackOverflow call stackoverflow#StackOverflow(<f-args>)
